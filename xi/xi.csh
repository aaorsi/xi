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

# To ensure that the parameters are passed correctly to the 
# program, the code will print all the above list. To avoid this
# set the following parameter to 'false'

set paramdir = 'pars/'
set RunName = $1
set nDD = $2
set nRR = $3

set fname = $4
set NRunDD = $5
set NRunRR = $6



#########
# Define here parameters specific to a particular run

if ($RunName == 'xi2d_sag') then 

  source $paramdir$RunName'.csh'
  set ParticleData = $DataDir$fname
  set OutName = 'xi2d_'$fname
  set OutDir = '/home/CEFCA/aaorsi/work/sag_mdpl/data/xidata/'$RunName'/'
  mkdir -p $OutDir
  set run = 'Data'	#	'Data', 'Random', 'All'

endif



if ($run == 'All') then 

		set OutDD = $OutDir'DD'$OutName'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$OutName'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$OutName'_'$NRunRR'.'$nRR


		./$XiSrc 'Data' $NRunDD $nDD $Seed $ParticleData \
		$RandomData $DataFormat $OutDir $Periodic $XLength \
		$YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour \
		$DensityField $MassAss $FPSizeX $LogBin $BinSize $RMin \
		$RMax $OutDD $OutDR $OutRR 

		./$XiSrc 'Random' $NRunRR $nRR $Seed $ParticleData \
		$RandomData $DataFormat $OutDir $Periodic $XLength $YLength \
		$ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField \
		$MassAss $FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR \
		$OutRR 

	echo ' Done! '	
	##
endif

if ($run == 'Data') then
	
	echo 'Running Data'
	
		set OutDD = $OutDir'DD'$OutName'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$OutName'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$OutName'_'$NRunRR'.'$nRR
		
		echo \
		$CorrType 'Data' $NRunDD $nDD $Seed $ParticleData $RandomData $DataFormat $OutDir $Periodic \
		$XLength $YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField $MassAss\
		$FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR $OutRR 


		$XiSrc \
		$CorrType 'Data' $NRunDD $nDD $Seed $ParticleData $RandomData $DataFormat $OutDir $Periodic \
		$XLength $YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField $MassAss\
		$FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR $OutRR 

endif

if ($run == 'Random') then
	
	echo 'Running Random'
	 
		set OutDD = $OutDir'DD'$OutName'_'$NRunDD'.'$nDD
		set OutDR = $OutDir'DR'$OutName'_'$NRunDD'.'$nDD
		set OutRR = $OutDir'RR'$OutName'_'$NRunRR'.'$nRR
		
		./$XiSrc \
		$CorrType 'Random' $NRunRR $nRR $Seed $ParticleData $RandomData $DataFormat $OutDir $Periodic \
		$XLength $YLength $ZLength $RandomFlag $Frac $NRun $CellSizeX $NNeighbour $DensityField $MassAss\
		$FPSizeX $LogBin $BinSize $RMin $RMax $OutDD $OutDR $OutRR 

#		@ nDD++
#	end
endif

