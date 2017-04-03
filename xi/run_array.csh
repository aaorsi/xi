#!/bin/tcsh

#$ -S /bin/tcsh
#$ -cwd

#foreach snap (99 70 61 54 41)
foreach snap (54)

./runxi.csh $snap

sleep 60

end
