#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <strings.h>

#include "allvars.h"
#include "proto.h"
/* The format of the input file(s) must be
specified here. The default (DataFormat = 1) will be a standard ASCII
format */
void read_data(char *filename, particle *Data)
{
	FILE *fin;
	unsigned long i;
	int ix,iy,iz;	
	Nfp = NFPX * NFPY * NFPZ;
	
	printf("Reading File %s\n",filename); fflush(stdout);
	
	if (!(fin = fopen(filename,"r")))
	{
		printf("Cannot open %s\n",filename); fflush(stdout);
		exit(0);
	}
	i=0;

	while (!feof(fin))
	{
		switch(DataFormat)
		{
			case 1:
// This is the default format
				fscanf(fin,"%f %f %f",&Data[i].x, &Data[i].y, \
				&Data[i].z);
				break;
			default:
				printf(" Data format not recognised. Can't read data");
				printf(" DataFormat: %d\n",DataFormat);
				printf(" Go through read_data.c for details...");
				exit(0);
				break;
		}
		Data[i].id = i;
		Data[i].weight = 1;
		i++;
	}
	fclose(fin);
	NRead = i;
	printf("%ld Particles read\n",NRead);	
}
