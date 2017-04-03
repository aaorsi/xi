//Allvars.h

#define Pi 3.141592654
#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))
#define dprinti(expr) printf(#expr " = %d\n", expr)
#define dprintf(expr) printf(#expr " = %f\n", expr)
#define dprints(expr) printf(#expr " = %s\n", expr)
#define SQR(a) ((a)*(a))
#define NCELLMAX 10000
#define NMAX 5000000
#define NBINMAX 100
#define NCHARMAX 255

typedef struct {
	unsigned long id;
	unsigned long ioc;	
	float weight;
	float x;
	float y;
	float z;
	float mark;
} particle;

extern unsigned long NData1, NData2,NRandom, NRead, Nfp;
extern int DataFormat, MassAss;
extern char OutDir[NCHARMAX], PeriodicFlag[NCHARMAX], DensityFieldFlag[NCHARMAX],LogBinFlag[NCHARMAX], RandomFlag[NCHARMAX];
extern char OutDD[NCHARMAX], OutDR[NCHARMAX], OutRR[NCHARMAX], Name[NCHARMAX], PType[NCHARMAX];
extern float CellSizeX, CellSizeY, CellSizeZ;
extern float FPSizeX, FPSizeY, FPSizeZ;
extern int NNeighbour;
extern int NCellX, NCellY, NCellZ;
extern unsigned int NCellTotal, NFPTotal;
extern unsigned int NFPX, NFPY, NFPZ;
extern int NRunXX, nXX, Seed;
extern int RanFrac, RanNRun, NNeighbour; 
extern float XLength, YLength, ZLength;
extern float BinSize, RMin, RMax, TotalWeight,MeanMark;
extern int NBins,nn;
extern char PBar[3];
