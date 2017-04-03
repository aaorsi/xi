;Simple test to Outfiles

pro plot2

	Nam = 'BAO_'
	num = [1,5,10,15,30,40]
	Wlt = '/gal/r3/aaorsi/BAO/Data/wlt_'			; Exact linear theory w(theta)
	Wtl = '/gal/r3/aaorsi/BAO/Data/linearxi.txt'	; Thin layer aproximation to w(theta)

	!P.Font = 1

	set_plot,'ps'
	device,filename = 'compare_depth.ps',/color,/landscape,SET_FONT='Times', /TT_FONT  

	defplotcolors
	col = [!red,!green, !blue, !orange, !dpink, !dyellow, !cyan]

	plotsym,0,/fill

	yr = [-0.0015,.49]
	xr = [19,109]
	
	nnum = n_elements(num)	
	!P.Charthick = 3
	!P.charsize = 1.4
	multiplot,[3,2],/square,mytitle=textoidl('\omega(\theta)'),$
	mxTitle = textoidl('\theta [arcm]'),mxTitSize = 1.7,$
	myTitsize = 1.7

	!P.Charthick=1

	r2a = (180.*60.)/!PI
;	r2a = 1.
	xyouts,20,yr[1] - 10^(5*alog10(-4)),'Depth [Mpc/h]:',charth=4
	
	wth = textoidl('\omega(\theta)')

;	xyouts,20,yr[1] - 10^(alog10(-5)),'Linear theory '+ wth,charth=4,color=!red
;	xyouts,20,yr[1] - 10^(5*alog10(-5)),'Thin-layer approximation',charth=4,color=!blue
	
	rc = dp(3.1)

	for i = 0,nnum-1 do begin

		Name = Nam + strn(num[i])
	
		File = '../Output/'+Name+'/Xi_'+Name

		rdfloat,File,r,xi,err,/sil,col=[1,2,6],skip=1
		rdfloat,Wlt+strn(num[i]),t_lt,w_lt,/sil
		rdfloat,Wtl,r_tl,xi_tl,/sil
		t_lt = t_lt * r2a
		theta = r/rc * r2a
		theta_tl = r_tl/rc * r2a

		plot,indgen(2),/nodata,$
		xthic=5,ythic=5,charth=3,xr = xr, yr = yr,$
		/xs, /ys

		oplot,theta,xi,ps = 8
		oplot,theta,xi,thic=3,line=2
		oplot,[1e-5,1e3],[0,0],lines=1,thic=3
		oploterror,theta,xi,err, ps=3,Errthi=4

		scale_nor = 40./rc * r2a
		K =interpol(w_lt,t_lt,scale_nor) / interpol(xi,theta,scale_nor)
;		K_tl = interpol(xi_tl, theta_tl, scale_nor) / interpol(xi,theta,scale_nor)
		print,'scale:',scale_nor
	
;		K = 1.
		k_tl = 1.		


		oplot,t_lt, w_lt/k,thic=4,color=!red
		oplot,theta_tl, xi_tl/k_tl, thic=4,color=!blue


		if i eq 0 then $
		legend,['Depth[Mpc/h]: '+strn(Num[i]), 'Linear theory', 'Thin-layer approximation'], charth=3,/right,charsiz=1.2,$
		box=0, textcolor=[!black, !red, !blue] else $
		legend,'Depth[Mpc/h]: '+strn(Num[i]), charth=3,/right,charsiz=1.2, box = 0

		multiplot
			
	endfor
			
	device,/close

end

