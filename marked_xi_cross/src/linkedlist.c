#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "allvars.h"
#include "proto.h"

void linkedlist(particle *part, unsigned long iadd[], long hoc[], unsigned long n)
{
	long icell[NCellTotal];
	long i, ic, ioc,index,ncheck, ncheck2;

	printf(" Building the linked list \n");fflush(stdout);

	for(i = 0; i<NCellTotal; i++)
	{
		icell[i] = 0;
		hoc[i] = -1;
	}

	printf("icell and hoc initialized ok. No problem there\n");fflush(stdout);

	dprinti(n); fflush(stdout);
	for(i=0;i<n;i++)
	{
		ioc = part[i].ioc;	
		iadd[i] = hoc[ioc];
		hoc[ioc] = part[i].id;
		icell[ioc]++;

/*
		if (i < 100 )
		{
			dprinti(i);
			dprinti(ioc);
			dprinti(iadd[i]);
			dprinti(hoc[ioc]);
			dprinti(icell[ioc]);
		}
		if (i == 100)
			exit(0);
*/

	}
	printf("LL generated. No problem there\n");fflush(stdout);

	
	ncheck = 0;
	ncheck2 = 0;
 
   for(ic=0;ic<NCellTotal;ic++)
   {
		index = hoc[ic];
        while( index >= 0 )
        {
            index = iadd[index];
            ncheck ++;
        }
        ncheck2 += icell[ic];
   }
 
   printf("checking done. No problem there\n");fflush(stdout);

   if (ncheck != n  || ncheck2 != n )
   {
      printf("There was a problem in the linked list\n");
      printf("%ld != %ld != %ld \n",n, ncheck, ncheck2);
      exit(1);
   }
	printf("Done \n"); fflush(stdout);
}
