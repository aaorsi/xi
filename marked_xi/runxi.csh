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
set NRunRR = 1
set periodic = 1
set clean = 0	# Warning, it will delete old log-files

#set Snap = 32
#set Dil = 0.001

#set DataDir = '/fdg/aaorsi/AGNOverdensities/data/'

foreach model (salpeter)


set DataDir = '/data3/aaorsi/SAG/idl/analysis/out/LineCat/'$model'/'
#set DataDir = '/fdg/aaorsi/Felipe_testxi/'
#set DataDir = '/gal/r3/aaorsi/HETDEX/data/'
#set DataDir = /data/rw16/aaorsi/Millennium/diluted/$Snap/
#set DataDir = /data/rw16/aaorsi/Millennium/$Snap/
#set DataDir = /gal/r3/aaorsi/xifiles/

set wd = `pwd`
cd $DataDir
#set ParticleData = `ls Halpha-1*`

set Lbin = 0.2
foreach Line ('Halpha' 'OII_3727' 'OIII_5007')
#foreach snap (99 70 61 54 41 31 21)
set snap = $1 
foreach CatMode ('Diff')
foreach LumBin (39.0 39.2 39.5 39.7 40.0 40.2 40.5 40.7 41.0 41.2 41.5 41.7 42.0 42.2 42.5 42.7 43.0 43.2 43.5 43.7 44.0 44.2 44.5 44.7)

set ParticleData = $Line'.'$CatMode'.Bin'$Lbin'.Lum'$LumBin'.Snap'$snap
set nfiles = 1
echo $nfiles

cd $wd
set Name = $ParticleData

set OutDir = 'Output/'$model'/'$Name'/'

set QType = ''

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
		set DDFile = 'Output/'$Name[$i]'/DD'$Name[$i]'_'$NRunDD'.'$nDD
		echo $DDFile
			echo $run $NRunDD $NRunRR $nDD $nRR $Name[$i] $DataDir $ParticleData[$i]
			qsub -N $Name[$i] -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name[$i] $DataDir $ParticleData[$i] $OutDir
			@ nDD++
	end
	@ i++
end


end
end
end
end	#foreach ends here
end
	if ($periodic == 1) then
		exit
	endif

	@ nDD = 1
	@ nRR = 1

	while ($nRR <= $NRunRR)
		set TaskName = $Name'_RR_'$NRunRR'_'$nRR
		set run = 'Random'
		qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name
	#	qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
#		xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name $i $Depth
	#	xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name
		@ nRR++
	end

	@ i++

end
		
