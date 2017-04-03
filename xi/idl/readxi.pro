;Program to read the Xi Output

pro readxi

	Name = 'Test_Binary'
	
	
	OutFile = '../Output/'+Name+'/Xi_'+Name

	NTaskDD = 20
	NTaskRR = 20

	DDFile = '../Output/'+Name+'/DD'+Name+'_'+strn(NTaskDD)
	DRFile = '../Output/'+Name+'/DR'+Name+'_'+strn(NTaskDD)
	RRFile = '../Output/'+Name+'/RR'+Name+'_'+strn(NTaskRR)

	OtherEstimators = 'no'
	Compare = 'no'
	

	if(Compare eq 'yes') then begin
		CompFile = '/gal/r3/aaorsi/BAO/Out/Cat/2e5/xi/xi12.2'
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

	if ( NTaskDD gt 1) then begin
		for i = 2,NTaskDD do begin	
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

	if ( NTaskRR gt 1) then begin
		for i = 2,NTaskRR do begin	
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
	Error = 2*sqrt((1 + xi_ls)/DD)

	Nr = n_elements(r)
	openw,1,OutFile
	printf,1,'#r	     xi_ls	     DDp	      DRp	      RRp    Error '
	for i = 0,nr - 1 do $
		printf,1,r[i],xi_ls[i],DDp[i],DRp[i],RRp[i], Error[i]
	close,1

	print,'r = ',transpose(r)
	print,'####'
	print,'xi(r) = ',transpose(xi_ls)


	set_plot,'X'
	window,0,retain=2
	plot,r,xi_ls
	

	end


