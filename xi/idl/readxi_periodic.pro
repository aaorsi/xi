;Program to read the Xi Output
;
;
pro run_readxi


;	ModelList = ['Sim.T.Imf.K.SSP.CB07.Pho.L1e1.Lmod.1.Bmod.1.AgeEm.0.Var.0', 'Sim.T.Imf.K.SSP.CB07.Pho.L1e1.Lmod.1.Bmod.1.AgeEm.0.Var.1']
	LineList = ['Halpha', 'OII_3727'] ;, 'OIII_5007']
;	SnapshotList = ['99','77','61','53']
	SnapshotList = ['70']
	SFRBinList = findgen(8)*0.5 -2.0
  SFRType = ['SFR','InstantSFR']

	Vol = 150.0^3
	;DataDir = '/home/aaorsi/work/SAG/idl/analysis/assembly_bias/out/Xi/'
	DataDir = '/home/aaorsi/work/xi/xi/Output/salpeter_new/'

	nsnap = n_elements(SnapshotList)
	nsfr  = n_elements(SFRBinList)
	nLines = n_elements(LineList)
	nType  = n_elements(SFRType)

	
	for iline = 0,NLines-1 do begin
		Line = LineList[iline]	
		for iz = 0,nsnap-1 do begin
			Snap = SnapshotList[iz]
			for is = 0,nsfr-1 do begin
			  SFRBin = strn(SFRBinList[is],len=4)
				for iT = 0,nType-1 do begin
				  Type = SFRType[iT]
					Name = Line+'.Diff.Bin0.5.'+Type+SFRBin+'.Snap'+Snap
					print,Name
			
					FileDD  = DataDir + Name
					;GalFile = '/home/aaorsi/work/SAG/idl/analysis/assembly_bias/out/LineCat/salpeter/'+Name
					GalFile = '/home/aaorsi/work/SAG/idl/analysis/out/LineCat/salpeter_new/'+Name
		
					openr,1,GalFile,err=Err
					close,1
					if Err ne 0 then begin
            print, 'File '+GAlFile+' not found.'
            continue
          endif
					readxi_periodic,DataDir,Name,GalFile,Vol
				endfor
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


