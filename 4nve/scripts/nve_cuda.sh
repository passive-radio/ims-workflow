#!/bin/sh

source ~/amber24_cuda/amber.sh
export CUDA_VISIBLE_DEVICES=0
export CUDA_HOME=/usr/local/cuda-12.4
export PATH=$PATH:/usr/local/cuda-12/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.4

## e.g. batch_id=00
if [[ -z $1 ]]; then
  echo "Please provide the batch id."
  exit 1
fi

## e.g. sample_id=01
if [[ -z $2 ]]; then
  echo "Please provide the sample id."
  exit 1
fi

if [[ -z $3 || -z $4 ]]; then
  echo "Please provide the residue id beging to end for shake ignoring."
  exit 1
fi

residue_beg=$3
residue_end=$4

prefix=$ROOT_DIR
script_dir=$prefix/4nve/scripts
base_output_dir=$prefix/4nve/output
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7
settings_template=$script_dir/nve_settings_template
settings=$script_dir/nve_settings

# remove existing setting files
if [[ -f $settings ]]; then
  rm $settings
fi

# create setting files. change RESIDUE_BEG-RESIDUE_END value for shake ignoring
sed -e "s|RESIDUE_BEG|${residue_beg}|g" \
    -e "s|RESIDUE_END|${residue_end}|g" \
    $settings_template > $settings

batch_id=$( printf %02d $1 )
sample_id=$( printf %02d $2 )

output_dir=$base_output_dir/${batch_id}_${sample_id}
mkdir -p $output_dir

# Select restart file based on the batch_id and sample_id
trajectory_num=$(((sample_id+1)*200000))
restart_file=$prefix/3sampling/output/$batch_id/sampling/md.rst_${trajectory_num}

echo "job start time" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

  pmemd.cuda \
  -O \
  -i $settings \
  -p $input_system_parrm \
  -c $restart_file \
  -ref $input_system_crd \
  -r $output_dir/md.rst \
  -o $output_dir/md.out \
  -x $output_dir/md.crd.nc \
  -v $output_dir/md.vel.nc \
  -inf $output_dir/md.info \
  -l $output_dir/md.log

echo "job end time  " `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log