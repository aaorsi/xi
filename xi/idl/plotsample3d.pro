;Simple test to Outfiles

pro plotsample3d

	Nam = '2e5'
	num = [1,5,10,15,30,40]		;Depth
	nsample = [40,15,8,5,2,2]	; # samples for each depth

	Wlt = '/gal/r3/aaorsi/BAO/Data/wlt_'			; Exact linear theory w(theta)
	Wtl = '/gal/r3/aaorsi/BAO/Data/linearxi.txt'	; Thin layer aproximation to w(theta)

;	!P.Font = 1

	set_plot,'ps'
;	device,filename = 'compare_depth3d.ps',/color,/landscape,SET_FONT='Helvetica', /TT_FONT  
	device,filename = 'compare_depth3d.ps',/color,/landscape

	defplotcolors
	col = [!red,!green, !blue, !orange, !dpink, !dyellow, !cyan]

	plotsym,0,/fill

	yr = [-0.0015,.0019]
	xr = [10,250]
	
	nnum = n_elements(num)	
	!P.Charthick = 3
	!P.charsize = 0.8
	multiplot,[3,2],/square,mytitle=textoidl('\xi (r)'),$
	mxTitle = textoidl('r [Mpc/h]'),mxTitSize = 1.7,$
	myTitsize = 1.7,mTitle = 'Samples with 2e5 particles'

	!P.Charthick=1

	r2a = 1.
;	r2a = 1.
	xyouts,20,yr[1] - 10^(5*alog10(-4)),'Depth [Mpc/h]:',charth=4
	
	wth = textoidl('\omega(\theta)')

;	xyouts,20,yr[1] - 10^(alog10(-5)),'Linear theory '+ wth,charth=4,color=!red
;	xyouts,20,yr[1] - 10^(5*alog10(-5)),'Thin-layer approximation',charth=4,color=!blue
	
	rc = dp(3.1)

	for i = 0,nnum-1 do begin
		for j = 1,nsample[i] do begin
			Name = 'BAO_'+strn(num[i])+'.'+strn(j)
			File = '../Output/'+Name+'/Xi_'+Name
			if j eq 1 then begin
				rdfloat,File,r,xi,err,/sil,col=[1,2,6],skip=1
				nr = n_elements(r)
				xiArr = fltarr(nr,nsample[i])
				medXi = fltarr(nr)
				xi10 = medxi
				xi90 = medxi
				Err = medxi
			endif else $	
			rdfloat,File,r,xi,err,/sil,col=[1,2,6],skip=1
			xiArr[*,j-1] = xi
		endfor
			
		theta = r
		
		thPlots = theta
	
		for j = 0,nr-1 do begin
			if nsample[i] gt 2 then begin
				medXi[j] = median(xiArr[j,*]) 
				percentiles,xiArr[j,*],p10,p90
				xi10[j] = p10
				xi90[j] = p90
			endif else begin
				medXi[j] = mean(xiArr[j,*])
				xi10[j] = (min(xiArr[j,*]))
				xi90[j] = (max(xiArr[j,*]))
			endelse			

			Err[j] = (xi90[j] - xi10[j])/2.

			if theta[j] lt xr[0] then thPlots[j] = xr[0]
			if theta[j] gt xr[1] then thPlots[j] = xr[1]
			
;			if medxi[j] lt yr[0] then medxi[j] = yr[0]
;			if medxi[j] gt yr[1] then medxi[j] = yr[1]

			if xi10[j] lt yr[0] then xi10[j] = yr[0]
			if xi10[j] gt yr[1] then xi10[j] = yr[1]
			
			if xi90[j] lt yr[0] then xi90[j] = yr[0]
			if xi90[j] gt yr[1] then xi90[j] = yr[1]

		endfor


		rdfloat,Wlt+strn(num[i]),t_lt,w_lt,/sil
		rdfloat,Wtl,r_tl,xi_tl,/sil
		t_lt = t_lt * r2a
		theta_tl = r_tl


; Variance
		
		xVar = [thPlots, reverse(thPlots), thPlots[0]]
		yVar = [xi10, reverse(xi90), xi10[0]]

		plot,indgen(2),/nodata,$
		xthic=5,ythic=5,charth=3,xr = xr, yr = yr,$
		/xs, /ys

		plots,xVar, yVar, lines=1,thic=6
		polyfill,xVar,yVar,/fill,color=!lgray	

		oplot,theta,medXi,ps = 8
		oplot,theta,medXi,thic=3,line=2
		oplot,[1e-5,1e3],[0,0],lines=1,thic=3
;		oploterror,theta,xi,err, ps=3,Errthi=4


		scale_nor = 10.
		K =interpol(w_lt,t_lt,scale_nor) / interpol(xi_tl,theta_tl,scale_nor)
;		K_tl = interpol(xi_tl, theta_tl, scale_nor) / interpol(xi,theta,scale_nor)
		print,'scale:',K
	
;		K = 1.
		k_tl = 1.		


;		oplot,t_lt, w_lt/k,thic=4,color=!red
		oplot,theta_tl, xi_tl/k_tl, thic=4,color=!blue

		plot,indgen(2),/nodata,$
		xthic=5,ythic=5,charth=3,xr = xr, yr = yr,$
		/xs, /ys,/noerase


		if i eq 0 then $
		legend,['Depth[Mpc/h]: '+strn(Num[i]), 'Linear Theory'], charth=3,/right,charsiz=1.2,$
		box=0, textcolor=[!black, !blue] else $
		legend,'Depth[Mpc/h]: '+strn(Num[i]), charth=3,/right,charsiz=1.2, box = 0
		legend,textoidl('N_{Sample}= ')+strn(nsample[i]),/left,/bottom,chart=3,$
		charsiz=1.0,box=0

		multiplot
			
	endfor
			
	device,/close

end

