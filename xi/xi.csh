#!/bin/tcsh

#$ -S /bin/tcsh
#$ -cwd

# Script to run Xi code. All main parameters are specified here.
# For fragmented runs, two parameters are specified when calling
# this script, NrunDD and NrunRR, which specifies the number 
# of fragments of DD and RR data used for each run. If 
# NRunDD or NRunRR are set to zero or 1, then there is only 1 
# output file.
# 
# DD Runs output fragments of DD and DR. RR Runs output 
# only RR Data. Then use readxi.pro found in idl/ to merge them
# into a single output file.


set BinSize = 1.0				# BinSize is in log-units if LogBin == 'true'
set Name = $6		#identifier of the output pair files

set run = $1	#	'Data', 'Random', 'All'

set NRunDD = $2
set NRunRR = $3

set nDD = $4
set nRR = $5

set XiSrc = 'src/Xi'	
set Seed = 38217
set DataDir = $7 
set ParticleData = $DataDir$8
#set DataDir = '/gal/r3/aaorsi/xi/src/test/'
#set ParticleData = $DataDir'sxds'
set RandomData = 'none'
set DataFormat = 1	# Input File format (see read_data.c for details)
#set OutDir = 'Output/'$Name'/'	#Directory with all fragmented output files, generic name
set OutDir = $9
mkdir -p $OutDir
set Periodic = 'true'

set XLength = 150.0
set YLength = 150.0
set ZLength = 150.0

#set XLength = 1340
#set YLength = 1340
#set ZLength = 1340

# Random cataloge parameters
set RandomFlag = 'false'
set Frac = 1	# NRandom / NData
set NRun = 1  # The number of times RR will be computed (for each fragment)

# Parameter for Cells
#set CellSizeX = 67
set CellSizeX = 50.0
set NNeighbour = 1

# Parameters for Density Field
set DensityField = 'false'
set MassAss = 1						#1: NGP, 2: CIC, 3: TSC
set FPSizeX = 10

set LogBin = 'false'
set RMin = 0.	# RMin and RMax are never specified in log-units
set RMax = 50.0

# To ensure that the parameters are passed correctly to the 
# program, the code will print all the above list. To avoid this
# set the following parameter to 'false'

set CheckParam = 'true'

echo $run

if ($run == 'All') then 

#	while ($nDD <= $NRunDD)

		set OutDD = $OutDir'DD'$Name'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$Name'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$Name'_'$NRunRR'.'$nRR

		set TaskName = $TaskN'DD_'$nDD
	
		echo $TaskName

#		qsub -N $TaskName $BatchQueue 
		./$XiSrc 'Data' $NRunDD $nDD $Seed $ParticleData \
		$RandomData $DataFormat $OutDir $Periodic $XLength \
		$YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour \
		$DensityField $MassAss $FPSizeX $LogBin $BinSize $RMin \
		$RMax $OutDD $OutDR $OutRR $CheckParam

#		@ nDD++
#	end

#	while ($nRR <= $NRunRR)
	
		set OutDD = $OutDir'DD'$Name'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$Name'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$Name'_'$NRunRR'.'$nRR
		
		set TaskName = $TaskN'RR_'$nRR
	
		echo $TaskName
	
#		qsub -N $TaskName $BatchQueue 
		./$XiSrc 'Random' $NRunRR $nRR $Seed $ParticleData \
		$RandomData $DataFormat $OutDir $Periodic $XLength $YLength \
		$ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField \
		$MassAss $FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR \
		$OutRR $CheckParam

#		@ nRR++
#	end

	echo ' Done! '	
	##
endif

if ($run == 'Data') then
	
	echo 'Running Data'
	 
#	while ($nDD <= $NRunDD)
	
		set OutDD = $OutDir'DD'$Name'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$Name'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$Name'_'$NRunRR'.'$nRR
		
#		qsub -N $TaskName $BatchQueue 

		echo \
		'Data' $NRunDD $nDD $Seed $ParticleData $RandomData $DataFormat $OutDir $Periodic \
		$XLength $YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField $MassAss\
		$FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR $OutRR $CheckParam


		$XiSrc \
		'Data' $NRunDD $nDD $Seed $ParticleData $RandomData $DataFormat $OutDir $Periodic \
		$XLength $YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField $MassAss\
		$FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR $OutRR $CheckParam

#		@ nDD++
#	end
endif

if ($run == 'Random') then
	
	echo 'Running Random'
	 
#	while ($nDD <= $NRunDD)
	
		set OutDD = $OutDir'DD'$Name'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$Name'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$Name'_'$NRunRR'.'$nRR
		
#		qsub -N $TaskName $BatchQueue 
		./$XiSrc \
		'Random' $NRunRR $nRR $Seed $ParticleData $RandomData $DataFormat $OutDir $Periodic \
		$XLength $YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField $MassAss\
		$FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR $OutRR $CheckParam

#		@ nDD++
#	end
endif

