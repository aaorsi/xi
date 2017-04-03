/*  Here a density field replaces the set of particles.
	Each new 'particle' will have a weight depending on 
	a particular mass assignment scheme */
 

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "allvars.h"

int iwrap(int i, int Ng)
{
printf("Using iwrap!\n");
int iw;
	if(i >= 1 && i <= Ng) 
		iw = i;
	else if (i > Ng)
		iw = i - Ng;	
	else if (i < 0)
		iw = i + Ng;
	return(iw);
}

void densityfield(particle *Data, particle *Field, unsigned long NRead)
{
	

	FILE *fout;
	char *OutDens;
	unsigned long i, j, k, ioc,idField;
	long ix, iy, iz, igx, igy, igz;
	float xf,yf,zf, vw, wx, wy, wz;
	long ig, jg, kg;
/*	 These loops assign each Field 'particle' a position (the centre 
	 of the cell) */

	printf("Creating Density Field\n ");

	dprinti(NFPZ);


	for(i = 0; i < NFPX; i++)
	{
		for(j = 0; j < NFPY; j++)
		{
			for(k = 0; k < NFPZ; k++)
			{
				idField = (long) (i + j*NFPX + NFPX*NFPY*k);
				Field[idField].id = idField;
				Field[idField].x =  FPSizeX*i + (FPSizeX * 0.5);
				Field[idField].y =  FPSizeY*j + (FPSizeY * 0.5);
				Field[idField].z =  FPSizeZ*k + (FPSizeZ * 0.5);				
				Field[idField].weight = 0;	
				if((strcmp(RandomFlag,"false") == 0) && (strcmp(PType,"Random") == 0))
					Field[idField].weight = 1;	
			}
		}
	}

// If no RandomFlag
if ((strcmp(RandomFlag,"false") == 0) && (strcmp(PType,"Random") == 0))
{
	printf("No Assingment scheme required!\n");
	return;
}

	//just to be sure...
/*	if (ZLength == 0)
		for (i = 0; i<Nfp; i++)
			Field[i].z = 0.0;
*/
	
//	NRead = Nfp;

/*	This loop assigns a weight to each Field 'particle',
	following a mass assignment scheme. */

	switch(MassAss)
	{
		case 1:
		/*Here the weight is determined by the number of particles
		on a given sub-cell */
			printf("Applying NGP scheme\n");

			for(i = 0; i < NRead-1; i++)
			{	
				ix = (int) (Data[i].x / FPSizeX);
				iy = (int) (Data[i].y / FPSizeY);
				iz = (int) (Data[i].z / FPSizeZ);
				idField = (long) (ix + iy*NFPX + NFPX*NFPY*iz);
				if(idField < Nfp && ix < NFPX && ix >=0 \
				&& iy < NFPY && iy >= 0 && iz < NFPZ && iz \
				>= 0)
				{
					Field[idField].weight++;
				}
			}
		break;
	
		case 2:
			printf("Applying CIC scheme\n");
// The CIC mass assignment scheme 
			for(i = 0; i < NRead-1; i++)
			{	
//			Rescale the particle coordinates to be in units of the grid
				xf = Data[i].x / FPSizeX;
				yf = Data[i].y / FPSizeY;
				zf = Data[i].z / FPSizeZ;	
		
				ix = floor(xf - 0.5);
				iy = floor(yf - 0.5);
				iz = floor(zf - 0.5);

/*	Here ix,iy,iz represents the coordinates of the 'first cell' that receives 
	a contribution by the particle */
			
				for (igx = ix; igx <= ix+1; igx++)
				{
					(strcmp(PeriodicFlag,"true") == 0) ? (ig = iwrap(igx, NFPX)) : (ig = igx);
					ig = igx;
					vw = fabs(xf - ig - 0.5);
//	CIC weight:
					(vw < 1.0) ? (wx = 1- vw) : (wx = 0); 
					for (igy = iy; igy <= iy + 1; igy++)
					{
						(strcmp(PeriodicFlag,"true") == 0) ? (jg = iwrap(igy, NFPY)) : (jg = igy);
						vw = fabs(yf - jg - 0.5);
						(vw < 1.0) ? (wy = 1- vw) : (wy = 0); 
				
						if (ZLength == 0) 
						{
							igz = 0;
							idField = (long) (igx + igy*NFPX + NFPX*NFPY*igz);
							if (idField <= Nfp && idField >= 0) 
							{
								Field[idField].weight = Field[idField].weight + wx*wy;
							}		
						}
						else
						{
							for (igz = iz; igz <= iz + 1; igz++)
							{
								(strcmp(PeriodicFlag,"true") == 0) ? (kg = iwrap(igz, NFPZ)) : (kg = igz);
								vw = fabs(zf - kg - 0.5);
								(vw < 1.0) ? (wz = 1- vw) : (wz = 0); 
								idField = (long) (igx + igy*NFPX + NFPX*NFPY*igz);
							if (idField <= Nfp && idField >= 0)
							{ 
								Field[idField].weight = Field[idField].weight + wx*wy*wz;
							}
							if (iz == NFPZ-1) 
								break;
							}
						}
					if (iy == NFPY-1)
						break;
					}	
				if (ix == NFPX-1)
					break;
				}
			}
		break;
			
		case 3:
//		TSC scheme
			printf("Applying the TSC scheme\n");
	
			for(i = 0; i < NRead-1; i++)
			{	
//			Rescale the particle coordinates to be in units of the grid
				xf = Data[i].x / FPSizeX;
				yf = Data[i].y / FPSizeY;
				zf = Data[i].z / FPSizeZ;	
		
				ix = floor(xf);
				iy = floor(yf);
				iz = floor(zf);
		
				for (igx = ix-1; igx <= ix+1; igx++)
				{							
					(strcmp(PeriodicFlag,"true") == 0) ? (ig = iwrap(igx, NFPX)) : (ig = igx);
					vw = fabs(xf - ig - 0.5);
//TSC weight:
					if (vw <= 0.5) 
						wx = 0.75 - SQR(vw);
					else if (vw <= 1.5)
						wx = 0.5 * SQR((1.5-vw));
					else 
						wx = 0;
					for (igy = iy-1; igy <= iy+1; igy++)
					{							
						(strcmp(PeriodicFlag,"true") ==0) ? (jg = iwrap(igy, NFPY)) : (jg = igy);
						vw = fabs(yf - jg - 0.5);
						if (vw <= 0.50) 
							wy = 0.75 - (vw*vw);
						else if (vw <= 1.50)
							wy = 0.5 * ((1.5-vw)*(1.5 - vw));
						else 
							wy = 0;

						if (ZLength == 0) 
						{
							igz = 0;
							idField = (long) (igx + igy*NFPX + NFPX*NFPY*igz);
							if (idField <= Nfp && idField >= 0 && ig < NFPX  \
								&& ig >= 0 && jg < NFPY && jg >= 0)
							{
								Field[idField].weight = Field[idField].weight + wx*wy;
							}
								
						}
						else
						{
							for (igz = iz-1; igz <= iz+1; igz++)
							{							
//								if((iz == (NFPZ-1) && igz == (NFPZ)) || (iz == 0 && igz == (-1)))
//									continue;
								(strcmp(PeriodicFlag,"true") == 0) ? (kg = iwrap(igz, NFPZ)) : (kg = igz);
								vw = fabs(zf - kg - 0.5);
								if (vw <= 0.5) 
									wz = 0.75 - SQR(vw);
								else if (vw <= 1.5)
									wz = 0.5 * SQR((1.5-vw));
								else 
									wz = 0;
								idField = (long) (igx + igy*NFPX + NFPX*NFPY*igz);
								if (idField <= Nfp && idField >= 0 && ig < NFPX-10  \
									&& ig >= 0 && ig < NFPY-10 && ig >= 0 && ig <NFPZ-10 \
									&& ig >= 0) 
								{
									Field[idField].weight = Field[idField].weight + wx*wy*wz;
								}
							}
						}
					}
				}
			}
			break;
			
		default:
			printf("densityfield.c: No valid assignment scheme selected. \n");	
			printf(" MassAssn: %d\n",MassAss);
			exit(0);
		break;
		
	}
	
	printf("Density field created\n");

#ifdef DEBUG
/*
	dprints(OutDir);
	OutDens = strcat(OutDir,"densityfield.dat");	
	printf("Writing density field file: %s\n",OutDens);
	fout = fopen(OutDens, "w");	
	for(i = 0; i<Nfp; i++) 
		fprintf(fout,"%f\t %f\t %f\t\t %f\n",Field[i].x, Field[i].y, Field[i].z, Field[i].weight);
	fclose(fout);
	printf("Done\n");
	exit(0);
*/
#endif
}


