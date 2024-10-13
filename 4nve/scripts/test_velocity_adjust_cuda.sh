#!/bin/sh

# Set appropriate environment
prefix=$ROOT_DIR
script_dir=$prefix/4nve/scripts
base_output_dir=$prefix/4nve/output
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7
settings_template=$script_dir/test_nve_settings_template
settings=$script_dir/test_nve_settings

test_output_dir=$base_output_dir/test
mkdir -p $test_output_dir

# Please update the conda/mamba environment name
env_name=base

# activate mamba or conda environment. Switch between mamba and conda
if command -v mamba &> /dev/null
then
    mamba activate $env_name
else
    conda activate $env_name
fi

# This script depends on the following python packages:
# These packages have to be installed in your conda/mamba environment.
# - numpy
# - netCDF4
# - cupy

batch_size=8000

# print job start time including batch size info
echo "adjust vel (cupy) start time " `date +'%Y%m%d %H:%M:%S'` "batch size: $batch_size" >> $test_output_dir/time.log
# time print format 0.00s
started_at=`date +%s.%3N`

python3 $script_dir/adjust_velocity_gpu.py \
    output/test/md.vel.nc \
    output/test/adjusted.vel.nc \
    --input_steps 1 -1 1 \
    --output_steps 2 -1 2 \
    --dt 0.0005 \
    --batch_size $batch_size \

# time print format 0.00s
ended_at=`date +%s.%3N`
elapsed_time=$(echo "scale=3; $ended_at - $started_at" | bc)
echo "adjust vel (cupy) end time" `date +'%Y%m%d %H:%M:%S'` "batch size: $batch_size" >> $test_output_dir/time.log
echo "elased time: $elapsed_time" "batch size: $batch_size" >> $test_output_dir/time.log