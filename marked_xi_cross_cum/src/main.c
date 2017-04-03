/*	Program to compute the correlation function
using pair counts. Based on XiPs by Raul  */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

#include "allvars.h"
#include "proto.h"
#include <gsl/gsl_rng.h>

int main(int argc, char *argv[])
{
	int i,j,k;
	long hocDD2[NCELLMAX];
	long hocRR[NCELLMAX];
/*    
	unsigned long iaddDD2[NMAX];
	unsigned long *iaddRR;
    unsigned long iaddDR[NMAX];
*/
	long *iaddDD2;
	long *iaddRR;
	long *iaddDR;
	
    double nDD[NBINMAX],nDR[NBINMAX],nRR[NBINMAX],nD1D2[NBINMAX];
	double dr, nbar, r[NBINMAX];
	particle *Read;
	particle *Data1,*Data2, *Data;
	particle *Random;
    char  ParticleData1[NCHARMAX], ParticleData2[NCHARMAX], RandomData[NCHARMAX];
	char CheckParamFlag[5], OutFile[NCHARMAX], OutDD[NCHARMAX], OutDR[NCHARMAX], \
	OutD1D2[NCHARMAX],OutShuffle[NCHARMAX];
	char buf1[10],buf2[10];
	float CellSizeX_old, FPSizeX_old;
	int xi,Shuffle,NShuffle;
	const gsl_rng_type *T;
	float aux1,aux2;
	
//	strcpy(PBar,"yes");
	strcpy(PBar,"no");

	iaddDD2 = (long *) malloc(NMAX * sizeof(long));
	iaddRR 	= (long *) malloc(NMAX * sizeof(long));
	iaddDR	= (long *) malloc(NMAX * sizeof(long)); 

//	system("clear");
//	Input Parameters:

	gsl_rng *rr;
	gsl_rng_env_setup();

	T = gsl_rng_default;
	rr = gsl_rng_alloc (T);

	

	if(argc < 28) 
	{	
		printf(" Input parameters are not correctly specified. \n Exiting... ");
		exit(0);
	}

	strcpy(PType,argv[1]);
	NRunXX 			= atoi(argv[2]);
	nXX				= atoi(argv[3]);
	Seed			= atoi(argv[4]);
	strcpy(ParticleData1,argv[5]);
	strcpy(ParticleData2,argv[6]);
	strcpy(RandomData,argv[7]);
	DataFormat		= atoi(argv[8]);
	strcpy(OutDir,argv[9]);
	strcpy(PeriodicFlag,argv[10]);
	XLength			= atof(argv[11]);
	YLength			= atof(argv[12]);
	ZLength			= atof(argv[13]);
	strcpy(RandomFlag,argv[14]);
	RanFrac			= atof(argv[15]);
	RanNRun			= atoi(argv[16]);
	CellSizeX		= atof(argv[17]);
	NNeighbour		= atoi(argv[18]);
	strcpy(DensityFieldFlag,argv[19]);
	MassAss			= atoi(argv[20]);
	FPSizeX			= atof(argv[21]);
	strcpy(LogBinFlag,argv[22]);
	BinSize			= atof(argv[23]);
	RMin			= atof(argv[24]);
	RMax			= atof(argv[25]);
	strcpy(OutD1D2,argv[26]);
	strcpy(OutDR,argv[27]);
	strcpy(OutRR,argv[28]);
	strcpy(CheckParamFlag,argv[29]);
	Shuffle			= atoi(argv[30]);
	NShuffle		= atoi(argv[31]);
	
//	Check that the Input Parameters are correctly passed:
//	if(strcmp(CheckParamFlag, "true") == 0)	
//	{
		printf(" INPUT CONFIGURATION: \n -------------------\n");
		printf(" Marked Cross-correlation function\n");
		printf("Current run parameters:\n");
		printf("	Data Type: %s\n",PType);
		printf("	Number of divisions: %d\n",NRunXX);
		printf("	Current fragment: %d\n",nXX);
		printf("	Data Format : %d\n",DataFormat);
		printf("	DD File: %s\n",OutDD);
		printf("	DR File: %s\n",OutDR);
		printf("	RR File: %s\n",OutRR);
		printf("Initial Seed %d\n", Seed);
		printf("Input/Output parameters\n");
		printf("	Particle File1: %s\n", ParticleData1);
		printf("	Particle File2: %s\n", ParticleData2);
		printf("	Random File: %s\n", RandomData);
		printf("	Output Directory: %s\n",OutDir);	
		printf("	Data Format: %d\n", DataFormat);
		printf("<Periodic Box>: %s\n",PeriodicFlag);
		printf("Sample lengths\n");
		printf("	Length in X: %f\n",XLength);
		printf("	Length in Y: %f\n",YLength);
		printf("	Length in Z: %f\n",ZLength);
		printf("Random sample parameters\n");
		printf("	NRandom / NData = %d\n",RanFrac);
		printf("	# RR and DR will be computed = %d\n",RanNRun);
		printf("Cell parameters\n");
		printf("	Cell size along X: %f\n",CellSizeX);
		printf("	Number of Neighbour-Levels: %d\n", NNeighbour);
		printf("<Density Field>? %s\n",DensityFieldFlag);
		printf("	Field-Particle Size along X: %f\n",FPSizeX);
		printf("	Mass assignment scheme: %d\n", MassAss);
		printf("<Logarithmic Bins>? %s\n", LogBinFlag);
		printf("	Bin Size: %f\n",BinSize);
		printf("	Min. Scale: %f\n",RMin);
		printf("	Max. Scale: %f\n##\n\n\n",RMax);fflush(stdout);
//	}
		
//	Defining additional variables from input parameters

		gsl_rng_set(rr,Seed);
		CellSizeX_old = CellSizeX;

		NCellX = floor(XLength/CellSizeX);
		CellSizeX += (XLength - (CellSizeX*NCellX))/NCellX;
		
		NCellY = floor(YLength/CellSizeX_old);
		CellSizeY = CellSizeX_old + (YLength - (CellSizeX_old*NCellY))/NCellY;

		if (ZLength == 0)		
		{
			NCellZ = 1;
			CellSizeZ = 1;
		}
		else
		{
			NCellZ = floor(ZLength/CellSizeX_old);
			if (ZLength < CellSizeX_old)
				NCellZ = 1;
			CellSizeZ = CellSizeX_old + (ZLength - (CellSizeX_old*NCellZ))/NCellZ;
		}	

		FPSizeX_old = FPSizeX;

		NFPX = floor(XLength/FPSizeX);
		FPSizeX += (XLength - (FPSizeX*NFPX))/NFPX;
		
		NFPY = floor(YLength/FPSizeX_old);
		FPSizeY = FPSizeX_old + (YLength - (FPSizeX_old*NFPY))/NFPY;
		
		if (ZLength == 0)
		{
			NFPZ = 1;
			FPSizeZ = 1;
		}
		else
		{	
			NFPZ = floor(ZLength/FPSizeX_old);
			if(ZLength < FPSizeX_old)
				NFPZ = 1;
			FPSizeZ = FPSizeX_old + (ZLength - (FPSizeX_old*NFPZ))/NFPZ;
		}

		NCellTotal = NCellX * NCellY * NCellZ;
		Nfp   = NFPX * NFPY * NFPZ;

		if(strcmp(LogBinFlag,"true") == 0)
		{
			RMin = log10(RMin);
			RMax = log10(RMax);
		}

			NBins = ceil((RMax - RMin)/BinSize + 1.0);

#ifdef DEBUG
		printf(" Adjusting Cell Sizes to: %4.1f %4.1f %4.1f\n",CellSizeX, CellSizeY, CellSizeZ);
		printf(" Number of Cells: %dx%dx%d=%d\n",NCellX,NCellY,NCellZ,NCellTotal);
		printf(" Adjusting Field particle sizes to: %4.1f %4.1f %4.1f\n",FPSizeX, FPSizeY, FPSizeZ);
		printf(" Number of Field particles: %dx%dx%d=%d\n",NFPX,NFPY,NFPZ,Nfp);fflush(stdout);
#endif
//
	if(strcmp(PType,"Data") == 0)
	{
	
		printf("OutFile: %s\n",OutDD);	

		printf("\n\n Data Points: \n");
        printf("----------------------------------------\n");		


		if(strcmp(DensityFieldFlag,"true") == 0)
		{	
			DataFormat = 0;					
			Read = (particle*) malloc(NMAX * sizeof(particle));
			printf(" For data1 allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
//			read_data(ParticleData1,Read);
			Data1 = (particle*) malloc(Nfp * sizeof(particle));
			printf(" For density field allocating %g Mb (%ld)\n",Nfp*sizeof(particle)/1024./1024.,Nfp);		
			densityfield(Read, Data1, NRead);
			NData1 = Nfp;
			free(Read);

			DataFormat = 1;
			Read = (particle*) malloc(NMAX * sizeof(particle));
			printf(" For data2 allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
//			read_data(ParticleData2,Read);
			Data2 = (particle*) malloc(Nfp * sizeof(particle));
			printf(" For density field allocating %g Mb (%ld)\n",Nfp*sizeof(particle)/1024./1024.,Nfp);		
			densityfield(Read, Data2, NRead);
			NData2 = Nfp;
			free(Read);


		} else 
		{
			DataFormat = 1;
			Data1 = (particle*) malloc(NMAX * sizeof(particle));
			printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
			read_data(ParticleData1,Data1,1);
			NData1 = NRead;

			DataFormat = 0;
			Data2 = (particle*) malloc(NMAX * sizeof(particle));
			printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
			read_data(ParticleData2,Data2,0);
			NData2 = NRead;
		}
		
		assigncell(Data1, NData1);	
		assigncell(Data2, NData2);	
        linkedlist(Data2,iaddDD2,hocDD2,NData2);

        counting(NData1,Data1,Data2,iaddDD2,hocDD2, nD1D2);

		MeanMark = 0;
		for (i = 0; i<NData2; i++)
			MeanMark += Data2[i].mark;
		MeanMark /= NData2;

		printf(" D1D2 pair counts done\n");
		write_xifile(OutD1D2,nD1D2,TotalWeight);

		if (Shuffle == 1) 
		{
			printf("Shuffling the marks %d times\n",NShuffle);
			for (i = 0; i<NShuffle; i++)
			{
					sprintf(OutShuffle,"%s.sh%d",OutD1D2,i);
//				printf("%s\n",OutShuffle);
				for (j = 0;j<NBins;j++)
					nD1D2[j] = 0;	// Clearing the pair counting

				for (j = 0;j<NData2; j++)	// Shuffling array
				{
//					printf("Data2[%d].mark = %f\n",j,Data2[j].mark);
					xi = floor((NData2 - 1) * gsl_rng_uniform (rr));
					aux1 = Data2[j].mark;
					aux2 = Data2[xi].mark;
					
					Data2[j].mark = aux2;
					Data2[xi].mark = aux1;
//					printf("Data2_shuffled[%d].mark = %f\n",j,Data2[j].mark);

				}
			
				counting(NData1,Data1,Data2,iaddDD2,hocDD2,nD1D2);
				write_xifile(OutShuffle,nD1D2,TotalWeight);
			}	
		}

/*
		if(strcmp(DensityFieldFlag,"true") == 0)
		{						
			if(strcmp(RandomFlag,"true") == 0)
			{
				Read = (particle*) malloc(NMAX * sizeof(particle));
				printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
//				read_data(RandomData,Read);
			}
			else
			{
				Read = (particle*) malloc(sizeof(particle));
				NRead = 1;
			}
			
			Random = (particle*) malloc(Nfp * sizeof(particle));
			printf(" For density field allocating %g Mb (%ld)\n",Nfp*sizeof(particle)/1024./1024.,Nfp);		
			densityfield(Read, Random,NRead);
			NRandom = Nfp;

		} else 
		{
			Random = (particle*) malloc(NMAX * sizeof(particle));
			printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
//			read_data(RandomData,Data1);
			NRandom = NRead;
		}

		assigncell(Random, NRandom);	
		linkedlist(Random,iaddRR,hocRR,NRandom);
   		counting(NData1,Data1,Random,iaddRR,hocRR, nDR);
		printf(" DR pair counts done\n");
		write_xifile(OutDR,nDR,TotalWeight);

*/
		
//		free(Random);
		free(Data1);
		free(Data2);
	}
	else if(strcmp(PType,"Random") ==0)
	{
		printf("\n\n Random Points: \n");
        printf("----------------------------------------\n");		

		if(strcmp(DensityFieldFlag,"true") == 0)
		{						
			if(strcmp(RandomFlag,"true") == 0 )
			{
				Read = (particle*) malloc(NMAX * sizeof(particle));
				printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
//				read_data(RandomData,Read);
			}
			else
			{
				Read = (particle*) malloc(sizeof(particle));
				NRead = 1;
			}		
			Random = (particle*) malloc(Nfp * sizeof(particle));
			printf(" For density field allocating %g Mb (%ld)\n",Nfp*sizeof(particle)/1024./1024.,Nfp);		
			densityfield(Read, Random,NRead);
			NRandom = Nfp;
		} else 
		{
			Random = (particle*) malloc(NMAX * sizeof(particle));
			printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
//			read_data(RandomData,Random);
			NRandom = NRead;
		}
		assigncell(Random, NRandom);	
	    linkedlist(Random,iaddRR,hocRR,NRandom);
        counting(NRandom,Random,Random,iaddRR,hocRR, nRR);
		printf(" RR pair counts done\n");
		write_xifile(OutRR,nRR,TotalWeight);
		free(Random);
	}
	else
	{
		printf("PType: %s\n",PType);
		printf("Particle type not well defined. Exiting!\n");
		exit(0);
	}

	printf("Part %d/%d done!\n\n",nXX,NRunXX);fflush(stdout);
	return 0;
}
