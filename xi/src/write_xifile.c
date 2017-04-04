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
  float r[NBins],rpi[NBins];
   
  fout = fopen(out,"w");
  printf("\n");
  printf("- writing pairs file %s",out);fflush(stdout);
  fprintf(fout,"%15.5f\n",Num);
  
  if (strcmp(CorrType,"xi2d") == 0)
  {
    for (i=0;i<NBins;i++)
    {
      for (j = 0; j < NBins; j++)
      {
        if(strcmp(LogBinFlag,"true") ==0) 
        {
          r[i] = pow(10,RMin + i*BinSize +BinSize/2.);
          rpi[j] = pow(10,RMin + j*BinSize +BinSize/2.);
        }
        else
        {  
          r[i] = RMin + i*BinSize +BinSize/2.;
          rpi[j] = RMin + i*BinSize +BinSize/2.;
        }
        
        idd = i + NBINMAX*j
        
        fprintf(fout,"%f \t %f \t %15.5f\n",r[i],rpi[j],d1[idd]);

      }
    }

  }
  else
  {
    for (i=0;i<NBins;i++)
    {
      if(strcmp(LogBinFlag,"true") ==0) 
        r[i] = pow(10,RMin + i*BinSize +BinSize/2.);
      else
        r[i] = RMin + i*BinSize +BinSize/2.;

      fprintf(fout,"%f \t %15.5f\n",r[i],d1[i]);
    }
  }
  
  fclose(fout);
  printf(" File written ok [%s]\n",out);

}
