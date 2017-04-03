;to test a simple grid

pro densitygrid,xarr,yarr,w,NCellX,NCellY,SizeX,SizeY,OutFile,TEST=test,COLOR = color

	if keyword_set(COLOR) then loadct,color $
	else loadct,0		;The default is the gray-scale

	NormW = 255./(max(w))
	nw = n_elements(w)

	C_min = 220
	C_max = 0
	
	wmin = (min(w[where(w ne 0)]))
	wmax = (max(w))
	
	dw = wmax - wmin
	dc = c_max - c_min + 0.

	m_w = (dc)/(dw)
	n_w = 0.5*((c_min + c_max) - m_w*(wmin + wmax))


	Title = 'NGP scheme'

;	window,0,retain=2,xsiz=600,ysize=600
	set_plot,'ps'
	device,filename=OutFile,/color,/landscape

	plot,indgen(2),xr = [0,NCellX*SizeX],yr=[0,NCellY*SizeY],/xs,/ys,/nodata,$
	xtit='x',ytitle = 'y',/isotropic,title = Title,charth=2

	; position = aspect(1.0)

	print,'Drawing the density field...'
	for i = 0l,nw-1 do begin

		coordx =  [xarr[i]-sizex/2.,xarr[i]+sizex/2.]
		coordy = [yarr[i] - sizey/2.,yarr[i] + sizey/2.]
		wx = [coordx, reverse(coordx), coordx[0]]
		wy = [coordy[0],coordy[0],coordy[1],coordy[1],coordy[0]]

		polyfill,wx,wy,/fill,color = (w[i] eq 0 ? 255 :(m_w * (w[i]) + n_w))
		plots,wx,wy,color = 200
	endfor
;		colorbar,/ylog,ncolors = 100,/nodisplay,$
;		/vertical, yticks=0, division= 10,bottom = c_min 


;Color Bar:

		BarSize = 0.3	; The smaller the number the larger the bar
		XCoor = [NCellX*SizeX*(1.1), NCellX*SizeX*(1.2)]
		YCoor = [NCellY*SizeY/2.]
		YFact = BarSize*NCellY*SizeY
		strl = 5
		NDiv = -1.		; NDiv = -1 produces a continum color bar
		dj =  ceil(-dc/NDiv)
		j = c_max
		k = 0

		for i = c_max,c_min do begin
			if NDiv eq -1 then j = i $
			else begin
				if k eq dj then begin
					j = i
					k = 0
				endif
			endelse
			plots,XCoor, [YCoor*(1. + i/YFact), YCoor*(1. + i/YFact)],$
			thick=8,color=j
			k++
		endfor	
		
;			plots,[XCoor,reverse(Xcoor),Xcoor[0]],[YCoor*(1 + c_max/YFact),$
;			YCoor*(1 + c_max/YFact), YCoor*(1 + c_min/YFact), YCoor*(1 + c_min/YFact),$
;			YCoor*(1 + c_max/YFact)],thic=2

		xyouts,XCoor[0] + XCoor[0]*0.013, YCoor*(1 + c_min/YFact)+YCoor*(1 + c_min/YFact)*0.03, 'Weight',charth=3,charsiz=0.8
		xyouts,XCoor[0] + XCoor[0]*0.021, YCoor*(1 + c_min/YFact)+YCoor*(1 + c_min/YFact)*0.01, '(log)',charth=3,charsiz=0.6
		xyouts, XCoor[1]+2, YCoor*(1 + c_min/YFact), strn(alog10(wmin),len= strl),charsiz=0.5,charth=3
		xyouts, XCoor[1]+2, YCoor*(1 + c_max/YFact), strn(alog10(wmax),len= strl),charsiz=0.5,charth=3
		
		plot,indgen(2),xr = [0,NCellX*SizeX],yr=[0,NCellY*SizeY],/xs,/ys,/nodata,$
		xtit='x',ytitle = 'y',/isotropic,/noerase,title = Title,charth=2
end




