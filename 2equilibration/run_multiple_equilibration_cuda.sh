#!bin/bash

source ~/amber24_cuda/amber.sh
export CUDA_VISIBLE_DEVICES=0
export CUDA_HOME=/usr/local/cuda-12.4
export PATH=$PATH:/usr/local/cuda-12/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.4

cnt_samples=$1
prefix=$ROOT_DIR
output_dir=$prefix/2equilibration/output

if [[ -z $cnt_samples ]]; then
  echo "Please provide the number of samples to run."
  exit 1
fi

echo "set of jobs start time" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

for cnt_run in $(seq 1 $cnt_samples); do
    bash $prefix/2equilibration/scripts/single_equilibrate_cuda.sh
    export CNT_RUN=$(( $cnt_run + 1 ))
done

echo "set of jobs end time  :" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log