;Simple test to Outfiles


pro plotxi

	Name = 'TestXi'

	
	NTaskDD = [1,2,5,10,25]
	NTaskRR = [1,2,5,10,25]


	set_plot,'ps'
	device,filename = 'TestXi.ps',/color
	defplotcolors

	plotsym,0,/fill

	plot,indgen(2),/nodata,xtitl='r[Mpc/h]',ytitle=textoidl('\omega(\theta)'),$
	position=aspect(1.0), xthic=3,ythic=3,charth=2,xr=[10,280],yr = [-0.001,0.004],$
	/xs, /ys


	for a = 0,n_elements(NTaskDD)-1 do begin

		DDFile = '../Output/'+Name+'/DD'+Name+'_'+strn(NTaskDD[a])
		DRFile = '../Output/'+Name+'/DR'+Name+'_'+strn(NTaskDD[a])
		RRFile = '../Output/'+Name+'/RR'+Name+'_'+strn(NTaskRR[a])

		OtherEstimators = 'no'
		Compare = 'yes'
	

		if(Compare eq 'yes') then begin
			CompFile = '/gal/r3/aaorsi/BAO/Out/Cat/2e5/xi/xi14.2'
			rdfloat,CompFile,logr,xi_comp,skip=2,col=[2,5],/sil
		endif
	

; Read DD and DR:

	DDF = DDFile + '.1'
	DRF = DRFile + '.1'

	openr,1,DDF
	readf,1,NData
	close,1

	rdfloat,DDF,r,DD,skip=1,/sil
	rdfloat,DRF,r,DR,skip=1,/sil

	if ( NTaskDD[a] gt 1) then begin
		for i = 2,NTaskDD[a] do begin	
			DDF = DDFile + '.'+strn(i)
			DRF = DRFile + '.'+strn(i)
			openr,1,DDF
			readf,1,NData_
			close,1
			rdfloat,DDF,r,DD_,skip=1,/sil
			rdfloat,DRF,r,DR_,skip=1,/sil
			DD = DD +  DD_
			DR = DR +  DR_
			NData = NData + NData_
		endfor
	endif

; Read RR:

	RRF = RRFile + '.1'

	openr,1,RRF
	readf,1,NRandom
	close,1

	rdfloat,RRF,r,RR,skip=1,/sil

	if ( NTaskRR[a] gt 1) then begin
		for i = 2,NTaskRR[a] do begin	
			RRF = RRFile + '.'+strn(i)
			openr,1,RRF
			readf,1,NRandom_
			close,1
			rdfloat,RRF,r,RR_,skip=1,/sil
			RR = RR +  RR_
			NRandom = NRandom +  NRandom_
		endfor
	endif

	
; Normalise
	
	nDD = NData*(NData-1.)
	nRR = NRandom*(NRandom-1.)
	nDR = NData * NRandom 

	DDp = DD/nDD 
	RRp = RR/nRR 
	DRp = DR/nDR

	xi_ls = (DDp - 2*DRp + RRp) / RRp 
	xi_hew = (DDp - DRp)/RRp
	xi_ham = (DDp*RRp)/(DRp^2)-1.
	xi_n = DDp/RRp - 1.
	xi_dp = DDp/DRp - 1.


	Error = 2*sqrt((1 + xi_ls)/DD)


	oplot,r,xi_ls,ps = 8,symsiz=0.5
	oplot,r,xi_ls, lines=(a + 1),thic=4
	oploterror,r,xi_ls,Error,ps=3


	if OtherEstimators eq 'yes' then begin
		oplot,r,xi_hew,lines=1,thic=3
		oplot,r,xi_ham,lines=2,thic=3
		oplot,r,xi_n,lines=3,thic=3
		oplot,r,xi_dp,lines=4,thic=3
	endif

	oplot,[1e-5,1e3],[0,0],thic=0.5,lines=1

	if Compare eq 'yes' then oplot,10^logr,xi_comp,$
	thick=2,color=!red

	if OtherEstimators eq 'yes' then $
		legend,['Landy-Szalay', 'Hewett', 'Hamilton', 'Natural', 'Davis-Peebles'],lines=indgen(5),thic=3,$
		/right,box=0,charth=3,pspac=1.5,charsiz=0.8,/bottom

;	legend,['Random Catalogue','2e6 particles'],charth=3,charsiz=0.5,/left,/bottom,box=0
endfor
	
	device,/close

end

