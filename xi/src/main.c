/*  Program to compute the correlation function
using pair counts. Based on XiPs by Raul  */


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

#include "allvars.h"
#include "proto.h"

int main(int argc, char *argv[])
{
  int i;
  long hocDD[NCELLMAX];
  long hocRR[NCELLMAX];
    long *iaddDD;
  long *iaddRR;
    long *iaddDR;
    //double nDD[NBINMAX],nDR[NBINMAX],nRR[NBINMAX];
    double *nDD,*nDR,*nRR;
  double dr, nbar, r[NBINMAX];
  particle *Read;
  particle *Data;
  particle *Random;
    char  ParticleData[NCHARMAX], RandomData[NCHARMAX];
  char OutFile[NCHARMAX], OutDD[NCHARMAX], OutDR[NCHARMAX], OutRR[NCHARMAX];
  char buf1[10],buf2[10];
  float CellSizeX_old, FPSizeX_old;
    
  strcpy(PBar,"yes");

//  system("clear");
//  Input Parameters:

  iaddDD = (long *) malloc(NMAX*sizeof(long));
  iaddRR = (long *) malloc(NMAX*sizeof(long));
  iaddDR = (long *) malloc(NMAX*sizeof(long));

  if(argc < 28) 
  { 
    printf(" Input parameters are not correctly specified. \n Exiting... ");
    exit(0);
  }

  int _i = 1;

  strcpy(CorrType,argv[_i++]);
  strcpy(PType,argv[_i++]);
  NRunXX      = atoi(argv[_i++]);
  nXX       = atoi(argv[_i++]);
  Seed      = atoi(argv[_i++]);
  strcpy(ParticleData,argv[_i++]);
  strcpy(RandomData,argv[_i++]);
  DataFormat    = atoi(argv[_i++]);
  strcpy(OutDir,argv[_i++]);
  strcpy(PeriodicFlag,argv[_i++]);
  XLength     = atof(argv[_i++]);
  YLength     = atof(argv[_i++]);
  ZLength     = atof(argv[_i++]);
  strcpy(RandomFlag,argv[_i++]);
  RanFrac     = atof(argv[_i++]);
  RanNRun     = atoi(argv[_i++]);
  CellSizeX   = atof(argv[_i++]);
  NNeighbour    = atoi(argv[_i++]);
  strcpy(DensityFieldFlag,argv[_i++]);
  MassAss     = atoi(argv[_i++]);
  FPSizeX     = atof(argv[_i++]);
  strcpy(LogBinFlag,argv[_i++]);
  BinSize     = atof(argv[_i++]);
  RMin      = atof(argv[_i++]);
  RMax      = atof(argv[_i++]);
  strcpy(OutDD,argv[_i++]);
  strcpy(OutDR,argv[_i++]);
  strcpy(OutRR,argv[_i++]);
  
  printf(" INPUT CONFIGURATION: \n -------------------\n");
  printf("Current run parameters:\n");
  printf("  Data Type: %s\n",PType);
  printf("  Number of divisions: %d\n",NRunXX);
  printf("  Current fragment: %d\n",nXX);
  printf("  Data Format : %d\n",DataFormat);
  printf("  DD File: %s\n",OutDD);
  printf("  DR File: %s\n",OutDR);
  printf("  RR File: %s\n",OutRR);
  printf("Initial Seed %d\n", Seed);
  printf("Input/Output parameters\n");
  printf("  Particle File: %s\n", ParticleData);
  printf("  Random File: %s\n", RandomData);
  printf("  Output Directory: %s\n",OutDir);  
  printf("  Data Format: %d\n", DataFormat);
  printf("<Periodic Box>: %s\n",PeriodicFlag);
  printf("Sample lengths\n");
  printf("  Length in X: %f\n",XLength);
  printf("  Length in Y: %f\n",YLength);
  printf("  Length in Z: %f\n",ZLength);
  printf("Random sample parameters\n");
  printf("  NRandom / NData = %d\n",RanFrac);
  printf("  # RR and DR will be computed = %d\n",RanNRun);
  printf("Cell parameters\n");
  printf("  Cell size along X: %f\n",CellSizeX);
  printf("  Number of Neighbour-Levels: %d\n", NNeighbour);
  printf("<Density Field>? %s\n",DensityFieldFlag);
  printf("  Field-Particle Size along X: %f\n",FPSizeX);
  printf("  Mass assignment scheme: %d\n", MassAss);
  printf("<Logarithmic Bins>? %s\n", LogBinFlag);
  printf("  Bin Size: %f\n",BinSize);
  printf("  Min. Scale: %f\n",RMin);
  printf("  Max. Scale: %f\n##\n\n\n",RMax);fflush(stdout);
//  }
    
//  Defining additional variables from input parameters

  if (strcmp(CorrType,"xi2d") == 0)
  {
    nDD = (double * ) malloc(NBINMAX*NBINMAX*sizeof(long));
    nDR = (double * ) malloc(NBINMAX*NBINMAX*sizeof(long));
    nRR = (double * ) malloc(NBINMAX*NBINMAX*sizeof(long));
  }
  else
  {
    nDD = (double * ) malloc(NBINMAX*sizeof(long));
    nDR = (double * ) malloc(NBINMAX*sizeof(long));
    nRR = (double * ) malloc(NBINMAX*sizeof(long));
  }

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

    NBins = (int) (RMax - RMin)/BinSize;

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
    Read = (particle*) malloc(NMAX * sizeof(particle));
    printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
    read_data(ParticleData,Read);
    Data = (particle*) malloc(Nfp * sizeof(particle));
    printf(" For density field allocating %g Mb (%ld)\n",Nfp*sizeof(particle)/1024./1024.,Nfp);   
    densityfield(Read, Data, NRead);
    NData = Nfp;
    free(Read);
  } else 
  {
    Data = (particle*) malloc(NMAX * sizeof(particle));
    printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
    read_data(ParticleData,Data);
    NData = NRead;
  }
  
  assigncell(Data, NData);  
  linkedlist(Data,iaddDD,hocDD,NData);
  if (strcmp(CorrType,"xi2d") == 0)
    counting_2d(NData,Data,Data,iaddDD,hocDD, nDD);
  else
    counting(NData,Data,Data,iaddDD,hocDD, nDD);

  
  printf(" DD pair counts done\n");
  write_xifile(OutDD,nDD,TotalWeight);

  if(strcmp(DensityFieldFlag,"true") == 0)
  {           
    if(strcmp(RandomFlag,"true") == 0)
    {
      Read = (particle*) malloc(NMAX * sizeof(particle));
      printf(" For data allocating %g Mb (%ld)\n",NMAX*sizeof(particle)/1024./1024.,NMAX);
      read_data(RandomData,Read);
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
    read_data(RandomData,Data);
    NRandom = NRead;
  }

  assigncell(Random, NRandom);  
  linkedlist(Random,iaddRR,hocRR,NRandom);
    counting(NData,Data,Random,iaddRR,hocRR, nDR);
  printf(" DR pair counts done\n");
  write_xifile(OutDR,nDR,TotalWeight);
  
  free(Random);
  free(Data);
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
      read_data(RandomData,Read);
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
    read_data(RandomData,Random);
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
  
  free(nDD);
  free(nDR);
  free(nRR);
  return 0;
}
