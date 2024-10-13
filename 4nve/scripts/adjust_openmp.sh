#!/bin/sh -eu
#PBS -l select=1:ncpus=8:mpiprocs=2:ompthreads=4
#PBS -l walltime=48:00:00

# Set appropriate environment
prefix=$PREFIX_1TQ3_AGAIN/charmmgui_again
traj=$PREFIX_1TQ3_AGAIN_CHARMM_TRAJ
output=$traj/4nve/output/${run}_${smp}
mkdir -p $output

# CURP env setting
module purge
module load gcc-toolset/11.4.0
module load openmpi/4.1.6
conda_path=$HOME/packages/miniconda3
eval "$($conda_path/bin/conda shell.bash hook)"
conda activate curp

set -xeu

# faster directory
tmp=/lwork/users/$USER/$PBS_JOBID
#mkdir $tmp
cd $tmp

echo "job start time" `date +'%Y%m%d %H:%M:%S'` >> $output/time.log

cp $traj/4nve/output/${run}_${smp}/md.vel.nc .

echo "copy end time " `date +'%Y%m%d %H:%M:%S'` >> $output/time.log

curp conv-trj -vel \
    -p $prefix/0structure/output/system.parm7 \
    -pf amber \
    -i md.vel.nc \
    -if netcdf \
    --irange 1 -1 1 \
    -o adjust.vel.nc \
    -of netcdf \
    --orange 2 -1 2 \
    adjust-vel > /dev/null

echo "adjust end time" `date +'%Y%m%d %H:%M:%S'` >> $output/time.log

cp ./adjust.vel.nc $traj/4nve/output/${run}_${smp}

#if [ -e $output/adjust.vel.nc ]; then rm $output/md.vel.nc; fi

echo "job end time  " `date +'%Y%m%d %H:%M:%S'` >> $output/time.log