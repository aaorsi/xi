#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>

#include "allvars.h"
#include "proto.h"

void selectcells(particle center, long nearcell[], float xoff[], float yoff[], float zoff[])
{
	int ic,jc,kc, ix, iy, iz;
	int ioff=0,joff=0,koff=0;
	int iic,jjc,kkc,j=0;
	float xoffl, yoffl,zoffl;
	
	ix = (int) (center.x/CellSizeX );
	iy = (int) (center.y/CellSizeY );
	iz = (int) (center.z/CellSizeZ );
	
	for(ic=ix-NNeighbour;ic<=ix+NNeighbour;ic++)
	{
		if(strcmp(PeriodicFlag,"true") ==0 )
		{
			ioff = (int) (((ic>=NCellX)?-1:0)*NCellX+((ic<0)?1:0)*NCellX);
			iic = ic + ioff;
			xoffl = (((ix-iic)>NNeighbour)?1:0)*XLength+(((ix-iic)<(-1*NNeighbour))?-1:0)*XLength;
		}
		else 
		{
			if(ic < 0 || ic >= NCellX)
				continue;
			xoffl = 0;		
			iic = ic;
		}

		for(jc=iy-NNeighbour;jc<=iy+NNeighbour;jc++)
		{
			if(strcmp(PeriodicFlag,"true") ==0 )
			{
				joff = (int) (((jc>=NCellY)?-1:0)*NCellY+((jc<0)?1:0)*NCellY);
				jjc = jc + joff;
				yoffl = (((iy-jjc)>NNeighbour)?1:0)*YLength+(((iy-jjc)<(-1*NNeighbour))?-1:0)*YLength;
			}
			else
			{
				if(jc < 0 || jc >= NCellY)
					continue;
				yoffl = 0;
				jjc = jc;		
			}
			for(kc=iz-NNeighbour;kc<=iz+NNeighbour;kc++)
			{
				if(strcmp(PeriodicFlag,"true") ==0 )
				{
					koff = (int) (((kc>=NCellZ)?-1:0)*NCellZ+((kc<0)?1:0)*NCellZ);
					kkc = kc + koff;
					zoffl = (((iz-kkc)>NNeighbour)?1:0)*ZLength+(((iz-kkc)<(-1*NNeighbour))?-1:0)*ZLength;
				}
				else
				{
					if(kc < 0 || kc >= NCellZ)
						continue;
					zoffl = 0;
					kkc = kc;		
				}

				xoff[j] = xoffl;
				yoff[j] = yoffl;
				zoff[j] = zoffl;
	
				nearcell[j] =  iic + NCellX*(jjc) + NCellY*NCellZ*(kkc);
				j++;

			}
		}
	}	
	
	nn = j;
}
	



