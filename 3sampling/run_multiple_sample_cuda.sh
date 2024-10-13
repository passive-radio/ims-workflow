#!/bin/sh

export CUDA_VISIBLE_DEVICES=0
export CUDA_HOME=/usr/local/cuda-12.4
export PATH=$PATH:/usr/local/cuda-12/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.4

prefix=$ROOT_DIR
script_dir=$prefix/3sampling/scripts
output_dir=$prefix/3sampling/output
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7

traj=$PREFIX_1TQ3_AGAIN_CHARMM_TRAJ

if [[ -z $1 || -z $2 ]]; then
  echo "Please provide the sample number range to run."
  exit 1
fi

if [[ -z $3 || -z $4 ]]; then
  echo "Please provide the residue id beging to end for shake ignoring."
  exit 1
fi

sample_beg=$1
sample_end=$2

residue_beg=$3
residue_end=$4

echo "set of jobs start time" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

for cnt_run in $(seq $sample_beg $sample_end); do
    export CNT_RUN=$( printf %02d $cnt_run )
    bash $script_dir/single_make_sample_cuda.sh $residue_beg $residue_end
    # export CNT_RUN=$(( $cnt_run + 1 ))
done

echo "set of jobs end time  :" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log