#!/bin/sh -eu
#PBS -l select=1:ncpus=8:mpiprocs=2:ompthreads=4
#PBS -l walltime=48:00:00

# Set appropriate environment
prefix=$ROOT_DIR
script_dir=$prefix/4nve/scripts
base_output_dir=$prefix/4nve/output
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7
settings_template=$script_dir/test_nve_settings_template
settings=$script_dir/test_nve_settings

test_output_dir=$base_output_dir/test

# CURP env setting
mamba activate curp-v1
# check if `curp -h` command works
echo "curp -h command output:" >> $test_output_dir/curp.log 
echo `curp -h` >> $test_output_dir/curp.log

# set -xeu

echo "adjust velocity (CURP) job start time" `date +'%Y%m%d %H:%M:%S'` >> $test_output_dir/time.log
started_at=`date +%s.%3N`

curp conv-trj -vel \
    -p $input_system_parrm \
    -pf amber \
    -i $test_output_dir/md.vel.nc \
    -if netcdf \
    --irange 1 -1 1 \
    -o $test_output_dir/adjust.vel.nc \
    -of netcdf \
    --orange 2 -1 2 \
    adjust-vel > /dev/null

ended_at=`date +%s.%3N`
elapsed_time=$(echo "scale=3; $ended_at - $started_at" | bc)
echo "adjust velocity (CURP) job end time  " `date +'%Y%m%d %H:%M:%S'` >> $test_output_dir/time.log
echo "elapsed time: $elapsed_time" >> $test_output_dir/time.log