# xi

Different codes will eventually be merged into one smart code. For now this code is a mess, but it works.

Quick guideline on how to run xi2d and get multipoles:

1. Create a new parameter file in xi/xi/pars/ following the example script
2. Add an "if" block specific to your run in both xi.csh and qsub_xi.csh
3. Run it
4. Check py/read_xi2d.py to read the output, store the combined xi2d and get the multipoles. This can also plot.Example run for read_xi2d.py:
```
./read_xi2d.py -i /home/CEFCA/aaorsi/work/sag_mdpl/data/xidata/xi2d_sag -n xi2d_by_OII_z1.h5.ascii -p --NRuns=20 --multipole
```
