#!/bin/bash

source ~/amber24_cuda/amber.sh
export CUDA_VISIBLE_DEVICES=0
export CUDA_HOME=/usr/local/cuda-12.4
export PATH=$PATH:/usr/local/cuda-12/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.4

prefix=$ROOT_DIR
script_dir=$prefix/2equilibration/scripts
output_dir=$prefix/2equilibration/output
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7

cnt_run=$( printf %02d $CNT_RUN )
output_dir=$output_dir/$cnt_run
mkdir -p $output_dir

echo "job start time" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

# Equilibrium system in multiple steps
coordinates=${prefix}/1minimization/output/optimize_whole_system/md.rst

for step in 1heat 2nvt 3npt;do
  mkdir -p $output_dir/$step
  cd $output_dir/$step
  pmemd.cuda \
    -O \
    -i $script_dir/${step}.input \
    -p $input_system_parrm \
    -c $coordinates \
    -ref $input_system_crd \
    -r md.rst \
    -o md.out \
    -x md.crd.nc \
    -inf md.info \
    -l md.log
  coordinates=$output_dir/$step/md.rst # Update initial structure for the next step
done

echo "job end time  :" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log