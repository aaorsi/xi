#!/bin/tcsh

#$ -S /bin/tcsh
#$ -cwd

# Script to run Xi code (all main parameters are defined in xi.csh )
# This script is used to run multiple jobs in CDM

set NSample = 10 
set Depth = 0

set NRunDD = 4
set NRunRR = 4

set DiluteFactor = '1.0'
set Tag = 'default'

@ i = 0

while ($i < $NSample)

	set FileName = 'dm_'$DiluteFactor'_'$i'.'$Tag

	set Name = $FileName
#set QType = '-l sh'
	set QType = '-l m -q medium64.q'
	set OutJob = `pwd`'/OutCDM/'$Name'/'
	mkdir -p $OutJob
	echo 'Outjob = ' $OutJob

	@ nDD = 1
	@ nRR = 1


	while ($nDD <= $NRunDD)

		set TaskName = $Name'_DD_'$NRunDD'_'$nDD
		set run = 'Data'
		qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $FileName
#	Queue for series of samples:
#		qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
#		xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
	#	 xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name

		@ nDD++
	end

	@ nDD = 1
	@ nRR = 1

	while ($nRR <= $NRunRR)
		set TaskName = $Name'_RR_'$NRunRR'_'$nRR
		set run = 'Random'
		qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $FileName
	#	qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
#		xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
	#	xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name
		@ nRR++
	end

	@ i++

end
		
