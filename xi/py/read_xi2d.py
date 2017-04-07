#!/usr/bin/python

# Script to combine the outputs of xi2d, produce a single output file
# and plot the resulting xi2d and obtain the correlation function multipoles
# 

import sys, getopt
import os.path
import numpy as np
import matplotlib.pyplot as plt
import xiutils as tools


def main(argv):

  RootDir           = '/home/CEFCA/aaorsi/work/sag_mdpl/data/xidata/'
  RunName           = ''
  MakePlots         = False
  ComputeMultipoles = False
  NTotGals          = 0
  BoxSize           = (1.0e3)**3
  OutputDir         = ''

  try:
    opts, args = getopt.getopt(argv,"hpn:o:i:",["help","name=","plot","multipoles","outputdir=","inputdir=","NRuns=","NTotGals="])
  except getopt.GetoptError:
    print 'read_xi2d.py -i <inputfile> -o <outputfile>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print 'test.py -i <inputfile> -o <outputfile>'
      sys.exit()
    elif opt in ("-p", "--plot"):
      MakePlots = True
    elif opt in ("-n", "--name"):
      RunName = arg
    elif opt in ("-o", "--outputdir"):
      OutputDir = arg
    elif opt in ("-i", "--inputdir"):
      InputDir = arg
    elif opt in ("--multipoles"):
      ComputeMultipoles = True
    elif opt in ("--NRuns"):
      NRuns = int(arg)
    elif opt in ("--NTotGals"):
      NTotGals = long(arg)
    
    if OutputDir == '': #i.e. if outputdir not specified
      OutputDir = InputDir

  ntot = 0
  for ichunk in np.arange(1,NRuns+1):
    file_i = '%s/DD%s_%s.%d' % (InputDir, RunName, NRuns,ichunk)
    if os.path.isfile(file_i):
      ff = open(file_i,'r')
      ng_chunk = np.long(float(ff.readline()))
      ntot += ng_chunk
      ff.close()

      rper_, rpar_, dd_ = np.loadtxt(file_i, usecols=(0,1,2),unpack=True,skiprows=1)
      
      if ichunk == 1: # First file creates the array that combines all outputs
        binsize = rpar_[1] - rpar_[0]
        rmin  = rper_.min() - binsize/2.
        rmax  = rper_.max() + binsize/2.
        nbins = int((rmax - rmin) / binsize + 1)
        rcenter = rpar_[0:nbins]
        print 'binsize %f\nrmin %f\nrmax %f\nnbins %f\n' % (binsize,rmin,rmax,nbins)
        dd  = np.zeros([nbins,nbins])
        vol = np.zeros([nbins,nbins])       

      for i in range(nbins):
        for j in range(nbins):
          idd = j + i*nbins
          dd[i,j] += dd_[idd]
            

    else:
      print 'ERROR: file %s not found' % file_i
      sys.exit()
  
    
  if (NTotGals > 0 and NTotGals != ntot):
    print 'WARNING: Total number of objects read from xi2d files: %ld != %ld' % (ntot, NTotGals)

  # Computing the volume for each bin [i,j]
  for i in range(nbins):
    for j in range(nbins):
      vol[i,j] = 2 * np.pi * binsize * ((rcenter[i]+binsize/2.)**2 - (rcenter[i]-binsize/2.)**2)

  ndens = ntot / BoxSize
  xi2d = dd / (ndens * vol * ntot) - 1

  fout = '%s/xi2d.%s.ascii' % (OutputDir,RunName)
  print 'Writing Xi2d to %s ' % fout
  ff = open(fout,'w')
  for i in range(nbins):
    for j in range(nbins):
      ff.write('%f %f %f\n' % (rcenter[i],rcenter[j],xi2d[i,j]))

  ff.close()

  if MakePlots:
    plt.figure(1)
    xpl = np.log10(xi2d.T)
    vmin = -0.5
    vmax = np.nanmax(xpl)
    nlev = 40
    print xpl.max()
    #plt.pcolormesh(rcenter,rcenter,np.log10(xi2d),cmap = plt.cm.coolwarm)
    plt.contourf(rcenter,rcenter,xpl,cmap=plt.cm.coolwarm,vmin=vmin,vmax=vmax,levels=np.linspace(vmin,vmax,nlev))
    plt.colorbar()
    plt.xlim([rcenter.min(),15])
    plt.ylim([rcenter.min(),15])

  if ComputeMultipoles:
    data = {'sigarr':rcenter,'piarr':rcenter,'xi2d':xi2d}
    sarr = np.logspace(-2,2.5,num=100)
    xileg = tools.build_multipoles_sigpi(sarr,data,r_int=rcenter)

    fout = '%s/xileg.%s.ascii' % (OutputDir,RunName)
    print 'Writing xi multipoles to %s ' % fout
    ff = open(fout,'w')
    for i in range(nbins):
      ff.write('%f %f %f %f\n' % (xileg['s'][i],xileg['xileg'][0,i],xileg['xileg'][1,i],xileg['xileg'][2,i]))

    ff.close()
    
    if MakePlots:
    
      plt.figure(2)
      s = xileg['s']
      xi0 = xileg['xileg'][0,:]
      xi2 = xileg['xileg'][1,:]
      plt.plot(s,s**2*xi0,label='Monopole')
      plt.plot.(s,-s**2*xi2,color='red',label='Quadrupole')
      plt.legend()
      

  if MakePlots:
    plt.show()

if __name__ == '__main__':
  main(sys.argv[1:])
