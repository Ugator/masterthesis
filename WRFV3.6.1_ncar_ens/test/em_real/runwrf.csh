#!/bin/csh
#
# LSF batch script to run the test MPI code
#
#BSUB -P P64000499                      # Project number 99999999
#BSUB -a poe                            # select poe
#BSUB -n 512                            # number of total (MPI) tasks (in this case one node)
#BSUB -R "span[ptile=16]"               # run a max of 32 tasks per node
#BSUB -J wrf                            # job name
#BSUB -o wrf%J.out                      # output filename
#BSUB -e wrf%J.err                      # error filename
#BSUB -W 0:05                           # wallclock time (HH:MM)     
#BSUB -q regular                        # queue
#
#source /usr/local/lsf/conf/cshrc.lsf
#
#cd /glade/p/work/$USER/WRF_DIRECTORY
#
#unsetenv MP_COREFILE_FORMAT
#
# the following needs to be done once
#./wrf.exe
mpirun.lsf ./wrf.exe
#
exit
