#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <strings.h>

#include "allvars.h"
#include "proto.h"

void assigncell(particle *Data, unsigned long n)
{

	unsigned long i, j;
	unsigned int ix, iy, iz;

	printf("assign.c\n");
	dprinti(n);

	for(i = 0; i < n ; i++)
	{	
	/*	Now I compute the [ix,iy,iz] coordinates of the cell
		this particle belongs to */
		ix = (int) (Data[i].x / CellSizeX);
		iy = (int) (Data[i].y / CellSizeY);
		iz = (int) (Data[i].z / CellSizeZ);
	/*  And now assign to each particle the id of the
		cell it belongs to */
		if (Data[i].x == XLength)
			ix = NCellX-1;
		if (Data[i].y == YLength)
			iy = NCellY-1;
		if (Data[i].z == ZLength)
			iz = NCellZ-1;


		Data[i].ioc = (long) (ix + NCellX*(iy) + (NCellX*NCellY)*(iz));

		if (ix > NCellX || iy > NCellY || iz > NCellZ)
		{
			printf("READ_DATA.c: Error when assigning particles to a given cell\n");
			printf("ix: %d iy: %d iz %d \n", ix,iy,iz);
			printf("NCellX: %d NCelly: %d NCellZ: %d \n", NCellX, NCellY, NCellZ);
			printf("x: %f y: %f z: %f \n", Data[i].x, Data[i].y, Data[i].z);
			exit(0);
		}
		
	}
}
