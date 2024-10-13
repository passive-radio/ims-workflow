#!/bin/bash
prefix=$ROOT_DIR
base_output_dir=$prefix/4nve/output

batch_beg=$1
batch_end=$2
cnt_samples=$3
residue_beg=$4
residue_end=$5

if [[ -z $batch_beg || -z $batch_end || -z $cnt_samples || -z $residue_beg || -z $residue_end ]]; then
  echo "Please provide the batch id begin, batch id end, number of samples, residue id beg, and residue id end for shake ignoring."
  exit 1
fi

sample_end=$((cnt_samples-1))

echo "set of jobs start time" `date +'%Y%m%d %H:%M:%S'` >> $base_output_dir/time.log

for batch_id in $(seq $batch_beg $batch_end); do
    batch_output_dir=$base_output_dir/$(printf %02d $batch_id)
    mkdir -p $batch_output_dir
    echo "batch $batch_id job start time" `date +'%Y%m%d %H:%M:%S'` >> $batch_output_dir/time.log

    for sample in $(seq 0 $sample_end); do
        bash $prefix/4nve/scripts/nve_cuda.sh $batch_id $sample_id $residue_beg $residue_end
    done
    
    echo "batch $batch_id job done" >> $batch_output_dir/time.log
done

echo "set of jobs end time  :" `date +'%Y%m%d %H:%M:%S'` >> $base_output_dir/time.log