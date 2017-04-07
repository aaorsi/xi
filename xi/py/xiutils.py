import numpy as np
import pylab as pl
import scipy
from scipy import interpolate
from scipy import integrate
from scipy import special 
from scipy.interpolate import interp1d
from scipy.interpolate import UnivariateSpline
import scipy.integrate as integral
#from astropy.cosmology import FlatLambdaCDM
from scipy.interpolate import RectBivariateSpline


def mod_legendre(ell, xx):
  if (ell == 0):
    return special.legendre(ell)(xx) #xx/xx
  elif (ell == 1):
    return special.legendre(ell)(xx)
  elif (ell == 2):
    return (2*2+1)*special.legendre(ell)(xx)
  elif (ell == -2):
    return (1-xx)**2
  elif (ell == 4):
    return (2*4+1)*special.legendre(ell)(xx)
  else:
    raise Exception('Polynomial not yet defined')


def build_multipoles_sigpi(sarr,data,minscale = 0.0,r_int=[]):
  """
    This function computes the multipoles using xi(sig,pi) instead of
    xi(s,mu).
  """  
  sigarr = data['sigarr'] #[:,0]
  piarr = data['piarr'] #[0,:]
  xisigpi = data['xi2d']
#  sarr = np.logspace(-4,2.5,num=100)
#  sarr = data['sigarr']
#  sarr = sigarr
  
  nsarr = len(sarr)
  npi = len(piarr)
  nsig = len(sigarr)

  s2d = np.zeros([nsig,npi])
  for i in range(nsig):
    for j in range(npi):
      s2d[i,j] = sigarr[i]**2 + piarr[j]**2
  
  xileg = np.zeros([4,nsarr])

  xi2d = RectBivariateSpline(sigarr,piarr,xisigpi * s2d,kx=1,ky=1)
#  import pdb ; pdb.set_trace()

  for _is in range(1,nsarr):
#   mumax = np.sqrt(1 - (minscale / sarr[_is])**2)
#   sel = np.where(muarr <= mumax)
    nmu = 401 
    muarr = np.linspace(1,0,num=nmu)
    dmu = muarr[1] - muarr[0]
    th = np.arccos(muarr)
    th1 = np.arccos(muarr[-1] + dmu)
    dth = th[1] - th[0]
    rparr = sarr[_is] * np.sqrt(1 - muarr**2)
    piarr = sarr[_is] * muarr
#    xi2d_sub = np.zeros(_is++2)
    xi2d_sub = np.zeros(nmu)
#    if scipy.__version__ > '9.9.9.9': 
    if scipy.__version__ > '0.13.9': 
      xi2d_sub = xi2d(rparr,piarr, grid=False)/(rparr**2 + piarr**2)
    else:
      for ir in range(nmu):
        xi2d_sub[ir] = xi2d(rparr[ir],piarr[ir])/(rparr[ir]**2 + piarr[ir]**2)

    for ill in range(4):
      ell = 2* ill  # ell corresponds to 0, 2 and 4 moments 
      if ill == 3: 
        Leg = mod_legendre(-2, muarr)
      else:
        Leg = mod_legendre(ell, muarr)
#      xileg[ill,_is] =  (0.5* (th[1] - th[0]) *  (xi2d_sub[0]*Leg[0]*np.sqrt(1 - muarr[0]**2)) + 
 #                        0.5 * (th[nmu-1] - th[nmu-2]) * (xi2d_sub[nmu-1]*Leg[nmu-1]*np.sqrt(1-muarr[nmu-1]**2)) + 
  #                       dth * np.sum(xi2d_sub * Leg * np.sqrt(1-muarr**2) ))

#      xileg[ill,_is] =  (0.5 * (th[1] - th[0]) *  (xi2d_sub[0]*Leg[0]*np.sqrt(1 - muarr[0]**2)) + 
 #                       0.5 * (th1 - th[-1]) * (xi2d_sub[-1]*Leg[-1]*np.sqrt(1-
  #                      muarr[-1]**2))) + integrate.trapz(xi2d_sub*Leg*np.sqrt(1-muarr**2),th)

      xileg[ill,_is] = integrate.trapz(xi2d_sub*Leg*np.sqrt(1-muarr**2),th)

  if r_int != []: 
    nr = len(r_int)
    f_xi0 =  interp1d(sarr,sarr**2*xileg[0,:],kind='linear')    
    f_xi2 =  interp1d(sarr,sarr**2*xileg[1,:],kind='linear')    
    f_xi4 =  interp1d(sarr,sarr**2*xileg[2,:],kind='linear')    
    f_pxi2 = interp1d(sarr,sarr**2*xileg[3,:],kind='linear')    

    xileg_int = np.zeros([4,nr])

    xileg_int[0,:] = f_xi0(r_int)/r_int**2
    xileg_int[1,:] = f_xi2(r_int)/r_int**2
    xileg_int[2,:] = f_xi4(r_int)/r_int**2
    xileg_int[3,:] = f_pxi2(r_int)/r_int**2

    return {'xileg':xileg_int,'s':r_int}
  else:  
    return {'xileg':xileg,'s':sarr}


def build_multipoles(data,minscale = 0.0):

  sarr = data['sarr'] #[:,0]
  muarr = data['muarr'] #[0,:]
  xismu = data['xiangle2d']
  ns = len(sarr)
  nmu = len(muarr)

  dmu = muarr[1] - muarr[0]

  xileg = np.zeros([4,ns])

  for ill in range(3):
    ell = 2* ill  # ell corresponds to 0, 2 and 4 moments 
    for _is in range(ns):
      mumax = np.sqrt(1 - (minscale / sarr[_is])**2)
      sel = np.where(muarr <= mumax)
      Leg = mod_legendre(ell, muarr[sel])
      xileg[ill,_is] = integrate.trapz(xismu[_is,sel]*Leg,muarr[sel]) + (dmu/2.*xismu[_is,sel[0][0]]*Leg[0] + 
                       dmu/2.*xismu[_is,sel[0][-1]]*Leg[-1])
#      xileg[ill,_is] = dmu * np.sum(xismu[_is,sel]*Leg)
      
  for _is in range(ns):
    Leg = mod_legendre(-2, muarr[sel])
    xileg[3,_is] = integrate.trapz(xismu[_is,sel]*Leg,muarr[sel])
#    xileg[3,_is] = dmu * np.sum(xismu[_is,sel]*Leg)

  return {'xileg':xileg,'s':sarr}


def xibar(rr, xi):

  nr = np.size(rr)
  xib = np.zeros((2,nr))

  for b in range(2):
    for ir in range(nr):
      xib[b,ir] = integrate.trapz(xi[0:ir] * rr[0:ir]**(2.0 * (b + 1)), rr[0:ir])
    xib[b,:] *= (2 * b + 3) / rr**(2. * b + 3.)
  return xib


def get_numbias(rg,rdm,xig,xidm,bscale=[40,70],plot=False):
  """
  Get the linear bias by taking the mean of the ratio of two correlation functions within
  a given scale
  """

  xidm_g = np.interp(rg,rdm,xidm)
  rsc = np.where((rg > bscale[0]) & (rg <= bscale[1]))
  rat = np.sqrt(xig[rsc]/xidm_g[rsc])
  mean_b = np.mean(rat)

  if plot:

#   xidm_hf   = '/home/CEFCA/aaorsi/data/misc/xi_Millennium_.z0.dat'
#   xhf = np.loadtxt(xidm_hf)
#   rhf = xhf[:,0]
#   xihf = xhf[:,1]
    pl.figure(1)
    pl.plot((rg),(rg**2*xig),label='galaxies')
    pl.plot((rg),(rg**2*xidm_g),label='camb linear theory')
    pl.plot((rdm),(rdm**2*xidm*1.608**2),label='camb linear theory')
    pl.figure(2)
    pl.plot(rg[rsc],rat)
#   pl.plot(xhf[:,0],xhf[:,1]*xhf[:,0]**2,color='red',label='halofit')
# import pdb; pdb.set_trace()
  
    a1 = pl.figure(1)

    pl.plot(([bscale[0],bscale[0]]),[-2,200],'--')
    pl.plot(([bscale[1],bscale[1]]),[-2,200],'--')

    pl.xlim([0,200])
    pl.ylim([-10,100])
    pl.legend()
    pl.show()
#    import pdb; pdb.set_trace()

  return mean_b

def get_intxi(r,xi, plot=False):
  """ 
  Returns the integral expression (xi-bar and xi-double-bar) of the 
  real-space correlation function used to compute the multipole expressions
  of xi including linear RSDs

  """

  nr = len(r)
  arg_xibar = xi* r**2 
  arg_xidbar = xi * r**4

# Extrapolate to r=0 using univariatespline function 

  extf_xibar = UnivariateSpline(r[0:5],arg_xibar[0:5],k=3)
  extf_xidbar = UnivariateSpline(r[0:5],arg_xidbar[0:5],k=3)

#  x_0 = np.append(1e-3,r)
 
  x_0 = r

  exb = np.append(extf_xibar(x_0),arg_xibar)
  exdb = np.append(extf_xidbar(x_0),arg_xidbar)

  exb = arg_xibar
  exdb = arg_xidbar

  int_xibar = np.zeros(nr)
  int_xidbar = np.zeros(nr)

  for i in range(nr-1):
    dr = (np.log10(x_0[i+1]) - np.log10(x_0[i]))/2. 
    dr1 = 10**(np.log10(x_0[i]) + dr)
    dr2 = 10**(np.log10(x_0[i]) - dr)
    ddr = (dr1 - dr2)
    
    int_xibar[i] = integral.trapz(exb[:i+1],x_0[:i+1])
    int_xidbar[i] = integral.trapz(exdb[:i+1],x_0[:i+1])

#    int_xibar[i] = ddr * np.sum(exb[:i])
 #   int_xidbar[i] = ddr * np.sum(exdb[:i])
 
#    import pdb ; pdb.set_trace()

    # int_xibar[i] = integral.trapz(exb[0:i+1],x_0[0:i+1])
 #    int_xidbar[i] = integral.trapz(exdb[0:i+1],x_0[0:i+1])

# int_xibar = integral.simps(arg_xibar,r)
# int_xi2bar = integral.simps(arg_xidbar,r)

  ints_xi = np.zeros(nr, dtype=[('r',(np.float)),('xibar',(np.float)),('xidbar',(np.float))])

  ints_xi['r'] = r
  ints_xi['xibar'] = (3./r**3) * int_xibar

  ints_xi['xidbar'] = (5./r**5) * int_xidbar

  if plot:
    a3 = pl.figure(3)
    pl.plot(r,r**2*xi,'o',label=r'$\xi(s)$')
    pl.plot(r,extf_xibar(r),color='red',linewidth=1,label='spline')
    pl.xlabel('r')
    pl.ylabel(r'$s^2\xi$')
    pl.legend()
    pl.show()
    import pdb; pdb.set_trace()

  return r, ints_xi




