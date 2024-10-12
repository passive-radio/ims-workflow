#!/bin/bash

prefix=$ROOT_DIR
script_dir=$prefix/2equilibration/scripts
output_dir=$prefix/2equilibration/output
input_system_parrm=$prefix/0structure/input/system.parm7
input_system_crd=$prefix/0structure/input/system.rst7

# Prepare output directory for each sample.
id_sample=$( printf %02d $ID_SAMPLE )
output_dir=$output_dir/$id_sample
mkdir -p $output_dir

echo "job start time" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

# Equilibrium system in multiple steps
coordinates=${prefix}/1minimization/output/optimize_whole_system/md.rst
for step in 1heat 2nvt 3npt;do
  mkdir -p $output_dir/$step
  cd $output_dir/$step
  mpirun -np 4 pmemd.MPI \
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