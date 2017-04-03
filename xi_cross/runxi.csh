#!/bin/tcsh

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

#set Snap = 32
#set Dil = 0.001

#set DataDir = '/gal/r3/aaorsi/emlines/out/mock/'
set DataDir = '/home/aaorsi/work/AGNOverdensities/data/'
#set DataDir = '/gal/r3/aaorsi/HETDEX/data/'
#set DataDir = /data/rw16/aaorsi/Millennium/diluted/$Snap/
#set DataDir = /data/rw16/aaorsi/Millennium/$Snap/
#set DataDir = /gal/r3/aaorsi/xifiles/

#set ParticleData = `ls Halpha-1*`
#set ParticleData1 = 'radio_cat_iz25'

#foreach iz (15 17 20 25)
#foreach lum (41.0 42.0 43.0)

set centralmodname = '_Fan14_full'
#set centralmodname = ''
set modname = '_Fan14.e2'

#foreach modname ('_Fan14_full' '_Fan14.e2')

#set centralmodname = ''
#set modname = ''


set zsp	= '_zspace'
#set zsp	= ''

set RT = 0


if ($RT == 0) then
	set GalName = 'lyalphaNoRT'
else
	set GalName = 'lyalphaShell'
endif 

set GalName = 'halpha'


# Uncomment for H-alpha catalogue
#set GalName = 'halpha'

foreach iz (29 25 20)
foreach lum (41.0 42.0)

foreach PartData ('radio' 'QSO')

#set ParticleData1 = 'radio_cat_iz'$iz
set ParticleData1 = $PartData'_cat_iz'$iz$centralmodname$zsp
set ParticleData2 = $GalName'_cat_iz'$iz$modname'_lha'$lum$zsp
set Name = 'cc_'$PartData'_'$GalName'_iz'$iz$modname'_'$lum$zsp

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

set wd = `pwd`

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
		set DDFile = $wd'/Output/'$Name[$i]'/DD'$Name[$i]'_'$NRunDD'.'$nDD
		echo $DDFile
#		if (-f $DDFile) then 
#			@ nDD++
#		else 
			#qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name[$i] $DataDir $ParticleData[$i]
			echo $run $NRunDD $NRunDR $nDD $nRR $Name[$i] $DataDir $ParticleData1[$i] $ParticleData2[$i]
			./xi.csh $run $NRunDD $NRunDR $nDD $nRR $Name[$i] $DataDir $ParticleData1[$i] $ParticleData2[$i]
#			qsub -v A1=$run,A2=$NRunDD,A3=$NRunDR,A4=$nDD,A5=$nRR,A6=$Name[$i],A7=$DataDir,A8=$ParticleData1[$i],A9=$ParticleData2[$i] ./xi.csh
			@ nDD++
#		endif
	end
	@ i++
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
