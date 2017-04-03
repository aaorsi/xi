
# --Choose your system

#SYSTYPE = "Quintor"
#SYSTYPE = "Titania"
SYSTYPE = "Basic"

ifeq ($(SYSTYPE), "Quintor")
	CC        = cc -g -C
	OPTIMIZE = 	-fast \
		-xO5 \
		-xlibmil \
		-fsimple=2 \
		-dalign \
		-fns \
		-fsingle \
		-ftrap=%none \
		-xbuiltin=%all \
		-xtarget=ultra3i -xcache=64/32/4:1024/64/4 \
	CFLAGS  = $(OPTIMIZE)  
	LIBS    = -lm -lmpi
endif

ifeq ($(SYSTYPE), "Titania")
	CC        = cc -g -C
	OPTIMIZE = 	-fast \
		-xO5 \
		-xlibmil \
		-fsimple=2 \
		-dalign \
		-fns \
		-fsingle \
		-ftrap=%none \
		-xbuiltin=%all \
		-xtarget=ultra3 -xcache=64/32/4:8192/512/1 \
		-xopenmp=parallel
	CFLAGS  = $(OPTIMIZE)  
	LIBS    = -lm 
endif

ifeq ($(SYSTYPE), "Basic")
	CC        = gcc
	OPTIMIZE = -g
	CFLAGS   = $(OPTIMIZE) # -I/usr/local/include # -DDEBUG
	LIBS = -lm  -lgsl -lgslcblas 
endif


#---------------------------------------------------------

EXEC   = Xi

OBJS   = main.o  allvars.o\
         	read_data.o assigncell.o densityfield.o linkedlist.o \
         	counting.o selectcells.o write_xifile.o byte_swap.o\
			

INCL   =  proto.h allvars.h byte_swap.h Makefile

#---------------------------------------------------------

$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o  $(EXEC)

$(OBJS): $(INCL)

clean:
	rm -f $(OBJS) $(EXEC) core

#---------------------------------------------------------

