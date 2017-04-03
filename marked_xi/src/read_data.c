#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <strings.h>

#include "allvars.h"
#include "proto.h"
#include "byte_swap.h"

/* The format of the input file(s) must be
specified here. The default (DataFormat = 1) will be a standard ASCII
format */
void read_data(char *filename, particle *Data)
{
	FILE *fin;
	long i,j;
	struct P
	{
		float x;
		float y;
		float z;
	};				

	struct Pv
	{	
		float x;
		float y;
		float z;
		float vx;
		float vy;
		float vz;
	};
	
	struct P Part;
	struct Pv Partv;
	int ijunk0,ijunk1;
	float fjunk0,fjunk1;

	printf("Reading File %s\n",filename); fflush(stdout);
	
	if (!(fin = fopen(filename,"r")))
	{
		printf("Cannot open %s\n",filename); fflush(stdout);
		exit(0);
	}
	i=0;

	switch(DataFormat)
	{

		case 1:
// This is the default format
			while (!feof(fin))
			{
				fscanf(fin,"%f %f %f",&Data[i].x, &Data[i].y,&Data[i].z);
//				fscanf(fin,"%d %f %f %f %f",&ijunk0,&Data[i].x, &Data[i].y,&Data[i].z,&fjunk1);
				Data[i].id = i;
				Data[i].weight = 1;
				if (ZLength == 0)
					Data[i].z = 0;
				i++;
			}
			break;
// Binary File. The first line is the number of particles
		case 2:
			
			fread(&i,sizeof(long),1,fin);	
			printf("Number of Particles: %d\n",i);
			for (j = 0; j<i; j++)
			{
				fread(&Part,sizeof(struct P), 1, fin);
				Data[j].x = Part.x;
				Data[j].y = Part.y;
				Data[j].z = Part.z;
				Data[j].id = j;
				Data[j].weight = 1;
	
				if(j < 40050 && j > 40000)
				{
					dprintf(Data[j].z);
					fflush(stdout);
				}
			}

			printf("Number of Particles: %d\n",j);
			break;	

//	Binary File, which includes both positions and velocities. First line is the number
//  of galaxies.

		case 3:
			
			fread(&i,sizeof(long),1,fin);	
			printf("Number of Particles: %d\n",i);
			fflush(stdout);
			for (j = 0; j<i; j++)
			{
				fread(&Partv,sizeof(struct Pv), 1, fin);
				Data[j].x = Partv.x;
				Data[j].y = Partv.y;
				Data[j].z = Partv.z;
				Data[j].id = j;
				Data[j].weight = 1;
	
				if(j < 40050 && j > 40000)
				{
					dprintf(Data[j].z);
				}
			}
			break;	

			default:
				printf(" Data format not recognised. Can't read data");
				printf(" DataFormat: %d\n",DataFormat);
				printf(" Go through read_data.c for details...");
				exit(0);
				break;
	}
	fclose(fin);
	NRead = i-1;
	printf("%ld Particles read\n",NRead);	
// Now the Particles are replaced by a density field
}
