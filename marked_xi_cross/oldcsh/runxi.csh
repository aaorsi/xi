#!/bin/tcsh
#$ -S /bin/tcsh
#$ -cwd

# Script to run Xi code (all main parameters are defined in xi.csh )
# This script is used to run multiple jobs in CDM

set compile = false

if ($compile == true) then
	cd src && gmake clean && gmake && cd ..
endif

set NRunDD = 1
set NRunDR = 1
set periodic = 1
set clean = 0	# Warning, it will delete old log-files

set ZSpace = 1
set NoRT   = 0

set Shuffle = 1
set NShuffle = 100

if ($ZSpace == 1) then 
	set ff = '_zspace'
else
	set ff = ''
endif 


if ($NoRT == 1) then
	set rt = '_noRT'
else
	set rt = ''
endif


#set Snap = 32
#set Dil = 0.001

#set DataDir = '/gal/r3/aaorsi/emlines/out/mock/'
set DataDir = '/data3/aaorsi/AGNOverdensities/data/'
set DataDir2 = '/data3/aaorsi/AGNOverdensities/out/markedcats/'



#set DataDir = '/gal/r3/aaorsi/HETDEX/data/'
#set DataDir = /data/rw16/aaorsi/Millennium/diluted/$Snap/
#set DataDir = /data/rw16/aaorsi/Millennium/$Snap/
#set DataDir = /gal/r3/aaorsi/xifiles/

set wd = `pwd`
#cd $DataDir
#set ParticleData = `ls Halpha-1*`
#set ParticleData1 = 'radio_cat_iz25'

#foreach iz (15 17 20 25)
#foreach lum (41.0 42.0 43.0)

foreach iz (29 25 20 17)
foreach lum (41.0 42.0)
foreach PartData ('radio')

foreach Property ('Mcold' 'MStellar' 'SFR' 'Z' 'sSFR' 'MagUV' 'EW')

#set ParticleData1 = 'radio_cat_iz'$iz
set ParticleData1 = $PartData'_cat_iz'$iz$ff
set ParticleData2 = $Property'_cat_lyalpha_iz'$iz'_lum'$lum$rt
set Name = 'marked_'$Property'_'$iz'_'$lum$ff$rt

#set ParticleData2 = 'QSO_cat_iz'$iz
#set Name = 'cc_radio_QSO_iz'$iz

#set ParticleData = (bower_0.24_f-16.5  bower_0.24_f-17.0)
#set nfiles = 2
#set nfiles = `ls -1 * |wc -l`
set nfiles = 1

#set Name = $ParticleData
#set QType = '-l es'
set QType = ''
#set QType = '-l m -q medium64.q'

#set nfiles = 32
@ i = 1
	
while ($i <= $nfiles) 

	set OutJob = `pwd`'/Log/'$Name[$i]'/'
	mkdir -p $OutJob
	echo 'Outjob = ' $OutJob

	if ($clean == 1) then
		\rm $OutJob/*
	endif

	@ nDD = 1
	@ nRR = 1


	while ($nDD <= $NRunDD)

		set TaskName = $Name[$i]'_DD_'$NRunDD'_'$nDD
		set run = 'Data'
		set DDFile = '/home/aaorsi/marked_xi_cross/Output/'$Name[$i]'/DD'$Name[$i]'_'$NRunDD'.'$nDD
		echo $DDFile
#		if (-f $DDFile) then 
#			@ nDD++
#		else 
			#qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name[$i] $DataDir $ParticleData[$i]
			echo $run $NRunDD $NRunDR $nDD $nRR $Name[$i] $DataDir $DataDir2 $ParticleData1[$i] $ParticleData2[$i]
			qsub -k oe -v A1=$run,A2=$NRunDD,A3=$NRunDR,A4=$nDD,A5=$nRR,A6=$Name[$i],A7=$DataDir,A8=$DataDir2,A9=$ParticleData1[$i],A10=$ParticleData2[$i],A11=$Shuffle,A12=$NShuffle ./xi.csh
			@ nDD++
#		endif
	end
	@ i++
end
end
end
end
end
end
end


	if ($periodic == 1) then
		exit
	endif

	@ nDD = 1
	@ nDR = 1

	while ($nDR <= $NRunDR)
		set TaskName = $Name'_DR_'$NRunDR'_'$nDR
		set run = 'Random'
		qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunDR $nDD $nDR $Name
	#	qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
#		xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
	#	xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name
		@ nDR++
	end

	@ i++

end		
