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

set DataDir = '/Users/aaorsi/work/Tomas/'

set ParticleData1 = 'central-catalogue-mh13.0-co-Mpc-z2.2.txt'
set ParticleData2 = 'hae-catalogue-Ha-25-co-Mpc-z2.2.txt'
set Name = 'test'
set nfiles = 1

set QType = ''
set wd = `pwd`
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
		echo $run $NRunDD $NRunDR $nDD $nRR $Name[$i] $DataDir $ParticleData1[$i] $ParticleData2[$i]
		./xi.csh $run $NRunDD $NRunDR $nDD $nRR $Name[$i] $DataDir $ParticleData1[$i] $ParticleData2[$i]
		@ nDD++
	end
	@ i++


end
	
  
  
  if ($periodic == 1) then
	echo 'No need to compute RR or DRs in this run.'
  echo 'Done.'
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
