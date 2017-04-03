;Program to read the Xi Output
;
;
pro run_readxi


;	ModelList = ['Sim.T.Imf.K.SSP.CB07.Pho.L1e1.Lmod.1.Bmod.1.AgeEm.0.Var.0', 'Sim.T.Imf.K.SSP.CB07.Pho.L1e1.Lmod.1.Bmod.1.AgeEm.0.Var.1']

	ModelList = ['lyalphaShell']
	SnapshotList = ['15','17','20','25','29']
	LumBinList = ['41.0','42.0','43.0']

	Vol = 500.0^3
	Bin = '1.0'

	nmod  = n_elements(ModelList)
	nsnap = n_elements(SnapshotList)
	nlum  = n_elements(LumBinList)

	for iz = 0,nsnap-1 do begin
		Snap = SnapshotList[iz]
		for il = 0,nlum-1 do begin
			LumBin = strn(LumBinList[il],len=4)
			for im = 0,nmod-1 do begin
				Model = ModelList[im]
				Name = Model + '_cat_iz'+Snap+'_lha'+LumBin
				DataDir = '/home/aaorsi/xi/Output/'
				print,Name
				FileDD  = DataDir + Name
				GalFile = '/fdg/aaorsi/AGNOverdensities/data/'+Name

				openr,1,GalFile,err=Err
				close,1
				if Err ne 0 then continue
				readxi_periodic,DataDir,Name,GalFile,Vol
			endfor
		endfor
	endfor

end		
			



pro readxi_periodic,DataDir,Name,GalFile,Vol

;	DataDir = '/home/aaorsi/xi/Output/'
	
;	vol = 500.0^3
	Binary = 0
		
;	Name = 'Target_test'
;	GalFile = 'particulas.dat'

	OutFile = DataDir+Name+'/Xi_'+Name

	NTaskDD = 1
	NTaskRR = 0

for jj = 0,n_elements(Name)-1 do begin

	openr,1,OutFile[jj],err=NoFile
	close,1
;	if NoFile eq 0 then begin
;		print,'File '+OutFile[jj]+' exists, skipping...'	
;		continue
;	endif

	DDFile = DataDir+Name[jj]+'/DD'+Name[jj]+'_'+strn(NTaskDD)

	DDF = DDFile + '.1'

	openr,1,DDF,err=err
	if err ne 0 then begin
		print,'file '+DDF+' not found, skipping...'
		continue
		close,1
	endif
	readf,1,NData
	close,1

	If Binary then begin
		NGals = 0l
		FF = '/gal/r3/aaorsi/xifiles/'+GalFile[jj]
		openr,1,FF
		readu,1,NGals
		close,1
		print,'Number of Particles=',NGals
	endif else $
		NGals = numlines(GalFile[jj])
	

	rdfloat,DDF,r,DD,skip=1,/sil

	if ( NTaskDD gt 1) then begin
		for i = 2,NTaskDD do begin	
			DDF = DDFile + '.'+strn(i)
			openr,1,DDF
			readf,1,NData_
			close,1
			rdfloat,DDF,r,DD_,skip=1,/sil
			DD = DD +  DD_
			NData = NData + NData_
		endfor
	endif

	bin = r[1]-r[0]	
;	print,bin
	DDp = DD/2.
	n = float(NGals)/vol
	npairav = 0.5 * NGals * n * (4./3)*!PI*( (r + bin/2.)^3 - (r - bin/2.)^3 )
	
	xi = DDp/npairav - 1.

	Error = 2 * sqrt((1 + xi)/DDp)

	Nr = n_elements(r)
	print,Outfile[jj]
	openw,1,OutFile[jj]

	printf,1,'#r	     xi'
	for i = 0,nr - 1 do $
		printf,1,r[i],xi[i],Error[i],format='(2(F15,"   "),(F15))'
	close,1

endfor

end


