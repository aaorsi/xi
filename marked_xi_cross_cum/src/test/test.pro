;to test a simple grid


densitygrid,w,NCellX,NCellY,SizeX,SizeY,TEST=test,COLOR = color

	if keyword_set(TEST) then goto, example
	if keyword_set(COLOR) then loadct,color $
	else loadct,0		;The default is the gray-scale

	NormW = 255./max(w)
	nw = n_elements(w)

	xarr = findgen(NCellX)*SizeX + SizeX/2.
	xarr = findgen(NCellY)*SizeY + SizeY/2.

goto, loop

example:

		w = [3,4,1,2]
		xarr = [.5,1.5,.5,1.5]
		yarr = [1.5,1.5,.5,.5]
		
		NCellX = 2
		NCellY = 2

		sizex = 1.
		sizey = 1.

		NormW = 255./max(w)

		nw = n_elements(w)

loop:

	plot,indgen(2),xr = [0,NCellX*SizeX],yr=[0,NCellY*SizeY],/xs,/ys,/nodata,$
	xtit='x',ytitle = 'y'

	for i = 0l,nw-1 do begin

		coordx =  [xarr[i]-sizex/2.,xarr[i]+sizex/2.]
		coordy = [yarr[i] - sizey/2.,yarr[i] + sizey/2.]
		wx = [coordx, reverse(coordx)]
		wy = [coordy[0],coordy[0],coordy[1],coordy[1]]

		print,'Color :',w[i]*NormW

		polyfill,wx,wy,/fill,color = w[i]*NormW
		plots,wx,wy,color = w[i]*Normw
	endfor



end




