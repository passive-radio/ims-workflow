#!/bin/bash

prefix=$ROOT_DIR
script_dir=$prefix/1minimization/scripts
input_dir=$prefix/1minimization/input
prev_input_dir=$prefix/0structure/input
output_dir=$prefix/1minimization/output
system_parm=$input_dir/system.parm7
mkdir -p $output_dir
mkdir -p $input_dir

# Copy the previous output files to the input directory.
cp $prefix/0structure/output/system.prmtop $input_dir/
cp $prefix/0structure/output/system.crd    $input_dir/

# debug
cp $0 $output_dir/job.sh # for debug purpose, save the job script to the output directory
if [ -e $output_dir/time.log ];then rm $output_dir/time.log; fi
echo "job start time:" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

# Optimize system in multiple steps
current_coordinates=$prev_input_dir/system.rst7
prmtop=$input_dir/system.prmtop
for step in optimize_hydrogen optimize_sidechain optimize_whole_system;do
  mkdir -p $output_dir/$step

  cp $script_dir/${step}.input $output_dir/$step/input

  cd $output_dir/$step

  mpirun -np 4 pmemd.MPI \
    -O \
    -i   $output_dir/$step/input \
    -p   $prev_input_dir/system.parm7 \
    -ref $prev_input_dir/system.rst7 \
    -c   $current_coordinates \
    -r   $output_dir/$step/md.rst \
    -o   $output_dir/$step/md.out \
    -inf md.info \
    -l   md.log

  current_coordinates=$output_dir/$step/md.rst # Update initial structure for the next step
done

echo "job end time  :" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log