#!/bin/tcsh
#$ -S /bin/tcsh
#$ -cwd

# Script to run Xi code (all main parameters are defined in xi.csh )
# This script is used to run multiple jobs in CDM

set compile = true

if ($compile == true) then
	cd src && gmake clean && gmake && cd ..
endif

set NRunDD = 10
set NRunRR = 1
set periodic = 1
set clean = 1	# Warning, it will delete old log-files

#set Snap = 32
#set Dil = 0.001

set DataDir = '/gal/r3/aaorsi/emlines/out/mock/'
#set DataDir = '/gal/r3/aaorsi/HETDEX/data/'
#set DataDir = /data/rw16/aaorsi/Millennium/diluted/$Snap/
#set DataDir = /data/rw16/aaorsi/Millennium/$Snap/
#set DataDir = /gal/r3/aaorsi/xifiles/

set wd = `pwd`
cd $DataDir
set FRoot = 'Halpha-16.0*'
set ParticleData = `ls $FRoot`
set BinSize = (2.5 5.0 10)

set nbin = 3

#set ParticleData = (bower_0.24_f-16.5  bower_0.24_f-17.0)
#set nfiles = 2
set nfiles = `ls -1 $FRoot |wc -l`
echo $nfiles

cd $wd


set QType = '-l es'
#set QType = '-l m -q medium64.q'

set Name = ($ParticleData)
#set nfiles = 32
@ ib = 1

while ($ib <= $nbin)

@ i = 1
	
while ($i <= $nfiles) 

	set Name_i = $Name[$i]'_bin'$BinSize[$ib]

	set OutJob = `pwd`'/OutCDM/'$Name_i'/'
	mkdir -p $OutJob
# 	echo 'Outjob = ' $OutJob

	if ($clean == 1) then
		\rm $OutJob/*
	endif

	@ nDD = 1
	@ nRR = 1


	while ($nDD <= $NRunDD)

		set TaskName = $Name_i'_DD_'$NRunDD'_'$nDD
		set run = 'Data'
		set DDFile = 'Output/'$Name_i'/DD'$Name_i'_'$NRunDD'.'$nDD
		if (-f $DDFile) then 
			@ nDD++
		else 
			qsub $QType -N $TaskName -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name_i $DataDir $ParticleData[$i] $BinSize[$ib]
		echo $DDFile
			@ nDD++
		endif
	end
	@ i++
end
#	echo $BinSize[$ib]
	@ ib++	
end

	if ($periodic == 1) then
		echo 'done!'
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

