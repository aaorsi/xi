#!/bin/tcsh

#$ -S /bin/tcsh
#$ -cwd

## Script to run Xi2d ##

set CorrType = 'xi2d' # xi2d, xi, xiproj, xicross, marked_xi, etc...  

set DataDir = '/home/CEFCA/aaorsi/work/sag_mdpl/data/'
set BinSize = 1.0				# BinSize is in log-units if LogBin == 'true'
set NRunDD = 40
set NRunRR = 1

set XiSrc = 'src/Xi'	
set Seed = 38217
#set DataDir = '/gal/r3/aaorsi/xi/src/test/'
#set ParticleData = $DataDir'sxds'
set RandomData = 'none'
set DataFormat = 1	# Input File format (see read_data.c for details)
set Periodic = 'true'

set XLength = 1000
set YLength = 1000
set ZLength = 1000

# Random cataloge parameters
set RandomFlag = 'false'
set Frac = 1	# NRandom / NData
set NRun = 1  # The number of times RR will be computed (for each fragment)

# Parameter for Cells
set CellSizeX = 40.0
set NNeighbour = 3

# Parameters for Density Field
set DensityField = 'false'
set MassAss = 1						#1: NGP, 2: CIC, 3: TSC
set FPSizeX = 10

set LogBin = 'false'
set RMin = 0.	# RMin and RMax are never specified in log-units
@ RMax = $CellSizeX * $NNeighbour

