#!bin/bash

# Tidy up the system by executing some amber commands.

echo "Tidying up the system."

if [[ $1 || $2 ]]; then
    forcefield_protein="leaprc.protein.$1"
    forcefield_water="leaprc.water.$2"
else
    echo "Forcefield names are not provided. Using ff14SB and TIP3P."
    forcefield_protein="leaprc.protein.ff14SB"
    forcefield_water="leaprc.water.tip3p"
fi

prefix=$ROOT_DIR
script_dir=$prefix/0structure/scripts
input_dir=$prefix/0structure/input
output_dir=$prefix/0structure/output
system_parm=$input_dir/system.parm7
mkdir -p $output_dir

input_pdb=$input_dir/system.pdb
output_pdb=$output_dir/system.pdb
output_prmtop=$output_dir/system.prmtop
output_crd=$output_dir/system.crd
script_template=$script_dir/create_prmtop_crd_template
script_file=$script_dir/create_prmtop_crd

if [[ -f $script_file ]]; then
    echo "Removing existing create_prmtop_crd script."
    rm -f $script_file
fi

if [[ -f $output_dir/system.prmtop ]]; then
    echo "System prmtop file already exists."
    rm -f $output_dir/system.prmtop
fi

if [[ -f $output_dir/system.crd ]]; then
    echo "System crd file already exists."
    rm -f $output_dir/system.crd
fi

cp $script_template $script_file

# Update create_promtop_crd script with given files.
sed -i "s|FORCEFIELD_PROTEIN|$forcefield_protein|" $script_file
sed -i "s|FORCEFIELD_WATER|$forcefield_water|" $script_file
sed -i "s|INPUT_PDB|$input_pdb|" $script_file
sed -i "s|OUTPUT_PDB|$output_pdb|" $script_file
sed -i "s|OUTPUT_PRMTOP|$output_prmtop|" $script_file
sed -i "s|OUTPUT_CRD|$output_crd|" $script_file

tleap -f $script_file