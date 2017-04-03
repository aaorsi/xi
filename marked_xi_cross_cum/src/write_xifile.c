#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

#include "allvars.h"
#include "proto.h"

void write_xifile(char *out,double d1[], float Num)
{
	int i;
	FILE *fout;
	
	NBins = floor((RMax - RMin)/BinSize);
	float r[NBins];
	 
	fout = fopen(out,"w");
	printf("\n");
    printf("- writing pairs file %s",out);fflush(stdout);
	fprintf(fout,"%15.5f\n",Num);
       	for (i=0;i<NBins;i++)
	{
		if(strcmp(LogBinFlag,"true") ==0) 
			r[i] = pow(10,RMin + i*BinSize +BinSize/2.);
		else
			r[i] = RMin + i*BinSize +BinSize/2.;

		fprintf(fout,"%f \t %15.5f\n",r[i],d1[i]/MeanMark);
	}
	fclose(fout);
	printf(" ok [%s]\n",out);

}
