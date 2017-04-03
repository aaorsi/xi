;Program to read the Xi Output

pro readxi_periodic

;	type = ['real_space','_zspace_x','_zspace_y','_zspace_z']
;	nt = n_elements(type)
;	for kk = 0,nt-1 do begin
;	typ = type[kk]
;	Dilute = 0.1
;	DataDir = '/gal/r3/aaorsi/HETDEX/data/'
;

	LogBins = 1

	DataDir = '/fdg/aaorsi/AGNOverdensities/data/'

	vol = 500.0^3
	Binary = 0
		
;	GalFile1 = 'radio_cat_iz25'


;	iz	   = ['15','17','20','25']
	iz	   = ['29','25','20','17']
	niz = n_elements(iz)

	PartData = ['radio']

	for ip = 0,n_elements(PartData)-1 do begin

		PData = PartData[ip]

	for sn = 0,niz-1 do begin
	snap = iz[sn]

;	GalFile1 = 'radio_cat_iz'+snap
	GalFile1 = PData+'_cat_iz'+snap

	lum = ['41.0','42.0']
	for il = 0,n_elements(lum)-1 do begin

;	Name = 'cc_radio_lyalphaShell_iz'+snap+'_'+lum[il]

	Name = 'cc_'+PData+'_lyalphaShell_iz'+snap+'_'+lum[il]
	GalFile2 = 'lyalphaShell_cat_iz'+snap+'_lha'+lum[il] 

	OutFile = '../Output/'+Name+'/Xi_'+Name

	NTaskDD = 1
	NTaskRR = 0

for jj = 0,n_elements(Name)-1 do begin

	openr,1,OutFile[jj],err=NoFile
	close,1
;	if NoFile eq 0 then begin
;		print,'File '+OutFile[jj]+' exists, skipping...'	
;		continue
;	endif

	DDFile = '../Output/'+Name[jj]+'/DD'+Name[jj]+'_'+strn(NTaskDD)

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
	endif else begin
		NGals1 = numlines(DataDir+GalFile1[jj])
		NGals2 = numlines(DataDir+GalFile2[jj])
	endelse	

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

	Nr = n_elements(r)
	bin = LogBins ? 10^0.25 : r[1]-r[0]	
	lBin = 0.25
	binArr = fltarr(n_elements(r))
	for i = 0,n_elements(r)-1 do $
		binArr[i] = (10^(alog10(r[i]) + lBin) - 10^(alog10(r[i]) - lBin))/2.

	bin = r[1]-r[0]
	print,bin

	DDp = DD
	n = float(NGals2)/vol
	npairavarr = fltarr(nr)
	npairav =  NGals1 * n * (4./3) * !PI * ( (r + binarr/2.)^3 - (r - binarr/2.)^3 )
;	npairav =  NGals1 * n * (4./3) * !PI * ( (r + bin/2.)^3 - (r - bin/2.)^3 )
	
	print,npairav
	print,DDp
	print,n
	xi = DDp/npairav - 1.
	Error = 2 * sqrt((1 + xi)/DDp)

	print,Outfile[jj]
	openw,1,OutFile[jj]

	printf,1,'#r	     xi'
	for i = 0,nr - 1 do $
		printf,1,r[i],xi[i],Error[i],format='(2(F15,"   "),(F15))'
	close,1

endfor

endfor
endfor
endfor
end
