

	File1 = 'Xi_BAO_2e6'
	File2 = 'Xi_BAO_2e5'

	rdfloat,File1,r,xi1,err1,col=[1,2,6],skip=1,/sil
	rdfloat,File2,r,xi2,err2,col=[1,2,6],skip=1,/sil

	XPol = [r,reverse(r),r[0]]

	Pol1 = [xi1 - err1, reverse(xi1 + err1), xi1[0] - err1]
	Pol2 = [xi2 - err2, reverse(xi2 + err2), xi2[0] - err2]

	XRange = [50,150.]
	YRange = [-4e-4,2e-3]

	npol = n_elements(XPol)

	for i = 0,npol-1 do begin
		if Xpol[i] lt XRange[0] then XPol[i] = XRange[0]
		if Xpol[i] gt XRange[1] then XPol[i] = XRange[1]
		if Pol1[i] lt YRange[0] then Pol1[i] = YRange[0]
		if Pol1[i] gt YRange[1] then Pol1[i] = YRange[1]
		if Pol2[i] lt YRange[0] then Pol2[i] = YRange[0]
		if Pol2[i] gt YRange[1] then Pol2[i] = YRange[1]
	endfor


	set_plot,'ps'
	device,filename = 'bao.ps',/color,/landscape

	defplotcolors
	plotsym,0,/fill

	plot,indgen(2),/nodata,xr=XRange,yr=YRange,/xs,/ys,$
	position = aspect(1.0), xthic=5,ythic=5,charth=4,xtitl = 'r[Mpc/h]',$
	ytitl=textoidl('w(\theta)')

;	polyfill,XPol, Pol1,/fill,color=!dgray
;	polyfill,XPol, Pol2,/fill,color=!gray

	plots,XPol, Pol1,lines=2,thic=3,color=!blue
	plots,XPol, Pol2,lines=2,thic=3

	oplot,r,xi1,ps=-8,syms=.7,color=!blue
	oplot,r,xi2,ps=-8,syms=.7
		
	oploterror,r,xi1,err1,ps=3,ERRCOL=!blue
	oploterror,r,xi2,err2,ps=3

	oplot,[1e-10,1e3],[0,0]

	plot,indgen(2),/nodata,xr=XRange,yr=YRange,/xs,/ys,$
	position = aspect(1.0), xthic=5,ythic=5,charth=4,xtitl = 'r[Mpc/h]',$
	ytitl=textoidl('w(\theta)'),/noerase

	legend,['Ng = 1.5e6','Ng = 2e5'],charth=3,textColo=[!blue,!black],box=0,/right


	device,/close

end

	
	
	
