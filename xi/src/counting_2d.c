
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

#include "allvars.h"
#include "proto.h"

void counting_2d(unsigned long n1,const particle *center,const particle *part, unsigned long iadd[], long hoc[],double xx[])
{
	unsigned int NCellFragment, Cell_init, Cell_last;
	unsigned int ih, j, ii, jj, min,sec,hashes, hashesTotal,idd;
	unsigned int u=(2*NNeighbour+1)*(2*NNeighbour+1)*(2*NNeighbour+1);
	long nearcell[u], index, i;
	float rsigma,rpi,dx,dy,dz,wc,wp;
	float xoff[u], yoff[u], zoff[u]; 
	time_t tstart,tnow;
	int step;
	TotalWeight = 0;
	
	NCellFragment = ceil((float) (NCellTotal) / (float) (NRunXX) );
	Cell_init = NCellFragment * (nXX -1);
	Cell_last = Cell_init + NCellFragment - 1;

	/* If NCell/nRunXX has a remainder, then the last fragment will be smaller
	   but there shouldn't be any error */

	printf(" Counting pairs from cells %d to %d\n",Cell_init, Cell_last); fflush(stdout);
	printf(" NCellFragment = %d / %d  = %d\n",NCellTotal, NRunXX, NCellFragment );

	printf("\t");
	(void) time(&tstart);
	for (i=0,j=0; i<NBINMAX, j<NBINMAX; i++, j++)
		idd = i + j * NBINMAX;
    xx[idd] = 0;

	step = (int) (RMax - RMin)/BinSize;

	for (i=0; i<n1; i++)
	{
		if (center[i].ioc <= Cell_last && center[i].ioc >= Cell_init)
		{	
			wc = center[i].weight;
			TotalWeight = TotalWeight +  wc;
			selectcells(center[i], nearcell, xoff,yoff,zoff);
			for (j=0; j<nn ; j++)
			{
				if   (nearcell[j] == -1 ) index = -1;
				else index = hoc[nearcell[j]];
				while( index >= 0)
				{
					wp = part[index].weight;
					dx = center[i].x - (part[index].x + xoff[j]);
					dy = center[i].y - (part[index].y + yoff[j]);
					dz = center[i].z - (part[index].z + zoff[j]);
			
					rsigma = sqrt(SQR(dx) + SQR(dy));
					rpi = sqrt(SQR(dz));
					
					if (strcmp(LogBinFlag,"true") ==0 )
					{
						rsigma = log10(rsigma);
						rpi = log10(rpi);
					}
					if ((rsigma <= RMax) && (rsigma >= RMin) && (rpi <= RMax) && (rpi >= RMin))
					{
						jj = (int) ((rpi - RMin)/BinSize);
						ii = (int) ((rsigma - RMin)/BinSize);
            idd = ii + NBINMAX*jj;
						xx[idd] += wc*wp;
					}
					index = iadd[index];
				}
			}
		}

		//printf(" %d \n",i); fflush(stdout);

		if(strcmp(PBar,"yes") ==0)
		{
	
			if (i % (long)(n1/100.+1) == 0 && i > 0)
			{
				(void) time(&tnow);
	
				hashesTotal = 50;
				hashes = (int) (( ((float) i) / ((float) n1) )*hashesTotal);
				min = (int) (tnow-tstart)/60.;
				sec = (int) (tnow-tstart)-min*60;

		        putchar('[');
       		    for (ih = 0; ih < hashes; ih++)
					putchar ('#');
           	   	for (; ih < hashesTotal; ih++)
					putchar ('-');
            	printf( "](%3d%%) %7ld/%7ld %3d:%2d", (int)(100.*(((float) i) / n1)), i,n1,min,sec  );
                for (ih = 0; ih < (hashesTotal + 31); ih++) putchar ('\b');
				fflush(stdout);

				//printf("\t %8.2ld \t \t %d \t %d \t \n", i,(int) (tnow-tstart), (int)((n1-i)*(tnow-tstart)/i) );
				}
		}
	}

//#pragma omp end parallel

	
	if(strcmp(PBar,"yes") ==0)
	{
		min = (int) (tnow-tstart)/60.;
		sec = (int) (tnow-tstart)-min*60;
	
   	    putchar('[');
		for (ih = 0; ih < hashesTotal; ih++)
			putchar ('#');

		printf( "](100%%) %7ld/%7ld %3d:%2d",i,n1,min,sec  );
   	    for (ih = 0; ih < (hashesTotal + 31); ih++) putchar ('\b');
		fflush(stdout);
		printf("\n");
	}
}	

