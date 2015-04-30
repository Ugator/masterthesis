#
# LSF batch script for WRF-Channel Model
#
#BSUB -P NMMM0001          # Your project number MUST go here
#BSUB -n 512             # number of total (MPI) tasks (in this case one node)
                           # 1n=8p ; 2n=16p
#BSUB -R "span[ptile=16]"   # run a max of 8 tasks per node
#BSUB -J ens_post_test     # job name
#BSUB -o wrf.out           # output filename
#BSUB -e wrf.err           # error filename
#BSUB -W 0:45              # wallclock time (HH:MM)
#BSUB -q regular         # queue

setenv TARGET_CPU_LIST -1
#mpirun.lsf ./real.exe
mpirun.lsf ./wrf.exe

exit
