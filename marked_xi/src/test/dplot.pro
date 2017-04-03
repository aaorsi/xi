;Plot the density Field

DensityData = 'densityfield.dat'
ParticleData = 'part1'
OutFile = 'dfield2_ngp.ps'

rdfloat,DensityData,xdf,ydf,zdf,w,/sile
rdfloat,ParticleData,xp,yp,zp,/sile

minx = min(xdf)
miny = min(ydf)
maxx = max(xdf)
maxy = max(ydf)

SizeX = xdf[1] - xdf[0]
XLength = maxx - minx + SizeX
NFPx = XLength / SizeX

SizeY = ydf[NFPX+1] - ydf[0]
YLength = maxy - miny + SizeY
NFPY = YLength / SizeY

;XLength = 1340.
;YLength = 1340.
;sizeX = 10.
;sizey = sizex
;NfpX = XLength/Sizex
;NFpy = YLength/SizeY


NPart = n_elements(xp)
NP_df = total(w)

print,'Number of Particles: ',nPart
print,'Number of particles mapped to the grid: ',NP_df

densitygrid,xdf,ydf,w,Nfpx,NfpY, sizex, sizey,outfile

loadct,3
plotsym,0,/fill
oplot,xp,yp,ps=8,symsi=0.1,color=100
device,/close


end
			
	


