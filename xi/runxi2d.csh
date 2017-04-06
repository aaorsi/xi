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
# TODO: Add variable parameters in an external file, leave this one as general-purpose as possible
source 
set DataDir = '/home/CEFCA/aaorsi/work/sag_mdpl/data/'
#set DataDir = '/fdg/aaorsi/Felipe_testxi/'
#set DataDir = '/gal/r3/aaorsi/HETDEX/data/'
#set DataDir = /data/rw16/aaorsi/Millennium/diluted/$Snap/
#set DataDir = /data/rw16/aaorsi/Millennium/$Snap/
#set DataDir = /gal/r3/aaorsi/xifiles/

set wd = `pwd`
cd $DataDir
#set ParticleData = `ls Halpha-1*`

set model = 'salpeter_new'
set snap = 70 
set SFRbin = 0.5
set CatMode = 'Diff'
foreach Line ('Halpha' 'OII_3727')
#foreach snap (99 70 61 54 41 31 21)
  foreach SFRcats ('-2.0' '-1.5' '-1.0' '-0.5' '0.00' '0.50' '1.00' '1.50')
    foreach SFRtype ('SFR' 'InstantSFR')

      set ParticleData = $Line'.'$CatMode'.Bin'$SFRbin'.'$SFRtype$SFRcats'.Snap'$snap
      set nfiles = 1
      echo $nfiles

      cd $wd
      set Name = $ParticleData

      set OutDir = 'Output/'$model'/'$Name'/'
      mkdir -p $OutDir
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
            #qsub -N $Name[$i] -e $OutJob -o $OutJob xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name[$i] $DataDir $ParticleData[$i] $OutDir
            ./xi.csh $run $NRunDD $NRunRR $nDD $nRR $Name[$i] $DataDir $ParticleData[$i] $OutDir
            @ nDD++
        end
        @ i++
      end
    end
  end
end

