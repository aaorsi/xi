#!/bin/tcsh
#$ -S /bin/tcsh
#$ -cwd

# Script to run Xi code (all main parameters are defined in xi.csh )
# This script is used to run multiple jobs in CDM

set compile = false
set RunName = 'xi2d_sag'



if ($RunName == 'xi2d_sag') then
  set NRunDD = 40
  set NRunRR = 1
  
  set filearr = ('by_OII_z1.h5.ascii')
  set nfiles = $#filearr

endif

if ($compile == true) then
	cd src && gmake clean && gmake && cd ..
endif

@ ifile = 1    

while ($ifile <= $nfiles)
  
  set Name = $filearr[$ifile]
  set OutJob = `pwd`'/Log/'$Name
  mkdir -p $OutJob
  echo 'Outjob = ' $OutJob

  @ nDD = 1
  @ nRR = 1

  while ($nDD <= $NRunDD)

    ./xi.csh $RunName $nDD $nRR $Name
    @ nDD++
  
  end
  @ ifile++
end

