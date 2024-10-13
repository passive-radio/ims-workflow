#!bin/bash

export CUDA_VISIBLE_DEVICES=0
export CUDA_HOME=/usr/local/cuda-12.4
export PATH=$PATH:/usr/local/cuda-12/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-12.4

residue_beg=1
residue_end=107


prefix=$ROOT_DIR
base_output_dir=$prefix/3sampling/output/00
script_dir=$prefix/3sampling/scripts
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7

pre_sampling0_template_file=/home/passiveradio/research/ch2-disulfide-bond/3sampling/scripts/pre_sampling0_template
pre_sampling1_template_file=/home/passiveradio/research/ch2-disulfide-bond/3sampling/scripts/pre_sampling1_template
sampling_template_file=/home/passiveradio/research/ch2-disulfide-bond/3sampling/scripts/sampling_template

pre_sampling0_input=/home/passiveradio/research/ch2-disulfide-bond/3sampling/scripts/pre_sampling0.input
pre_sampling1_input=/home/passiveradio/research/ch2-disulfide-bond/3sampling/scripts/pre_sampling1.input
sampling_input=/home/passiveradio/research/ch2-disulfide-bond/3sampling/scripts/sampling.input

# remove existing setting files
if [[ -f $pre_sampling0_input ]]; then
  rm $pre_sampling0_input
fi
if [[ -f $pre_sampling1_input ]]; then
  rm $pre_sampling1_input
fi
if [[ -f $sampling_input ]]; then
  rm $sampling_input
fi

# create setting files. change RESIDUE_BEG-RESIDUE_END value for shake ignoring
sed -e "s|RESIDUE_BEG|${residue_beg}|g" \
    -e "s|RESIDUE_END|${residue_end}|g" \
    $pre_sampling0_template_file > $pre_sampling0_input

sed -e "s|RESIDUE_BEG|${residue_beg}|g" \
    -e "s|RESIDUE_END|${residue_end}|g" \
    $pre_sampling1_template_file > $pre_sampling1_input

sed -e "s|RESIDUE_BEG|${residue_beg}|g" \
    -e "s|RESIDUE_END|${residue_end}|g" \
    $sampling_template_file > $sampling_input


echo "job start time" `date +'%Y%m%d %H:%M:%S'` >> $base_output_dir/time.log

# Sampling system in multiple steps
coordinates=$base_output_dir/pre_sampling1/md.rst
for step in sampling;do
  
  output_dir=$base_output_dir/$step
  mkdir -p $output_dir
  cd $output_dir

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

  coordinates=$output_dir/md.rst # Update initial structure for the next step
done

echo "job end time  " `date +'%Y%m%d %H:%M:%S'` >> $base_output_dir/time.log