#include "allvars.h" 
unsigned long NData, NRandom, NRead, Nfp;
 int DataFormat, MassAss;
 char OutDir[NCHARMAX], PeriodicFlag[NCHARMAX], DensityFieldFlag[NCHARMAX],LogBinFlag[NCHARMAX], RandomFlag[NCHARMAX];
 char OutDD[NCHARMAX], OutDR[NCHARMAX], OutRR[NCHARMAX], Name[NCHARMAX], PType[NCHARMAX],CorrType[NCHARMAX];
 float CellSizeX, CellSizeY, CellSizeZ;
 float FPSizeX, FPSizeY, FPSizeZ;
 int NNeighbour;
 int NCellX, NCellY, NCellZ;
 unsigned int NCellTotal, NFPTotal;
 unsigned int NFPX, NFPY, NFPZ;
 int NRunXX, nXX, Seed;
 int RanFrac, RanNRun, NNeighbour; 
 float XLength, YLength, ZLength;
 float BinSize, RMin, RMax, TotalWeight;
 int NBins,nn;
 char PBar[3];
