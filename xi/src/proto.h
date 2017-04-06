void read_data(char *, particle *);
void assigncell(particle *, unsigned long );
void linkedlist(particle *,unsigned long *, long *,unsigned long );
int iwrap(int *, int *);
void densityfield(particle *, particle *, unsigned long );
void counting(unsigned long ,const particle *,const particle *,unsigned long *,long *, double *);
void counting_2d(unsigned long ,const particle *,const particle *,unsigned long *,long *, double *);
void selectcells(particle , long *, float *, float *, float *);
void write_xifile(char *, double *, float );

