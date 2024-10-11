#!bin/bash

# This script creates a dry system with no water and solvent ions.
# Usage: ./dry_system.sh [solvent_ion1] [solvent_ion2]
# If solvent_ion1 and solvent_ion2 are not provided, Na+ and Cl- are used as default.
# The script outputs system.dry.prmtop, system.dry.crd, and system.dry.pdb files in the output directory.

echo "This script creates a dry system with no water molecules and solvent."

if [[ $1 || $2 ]]; then
    echo "Ions to strip are provided. using $1 and $2."
    solvent_ion1=$1
    solvent_ion2=$2
else
    echo "Ions to strip are not provided. Using Na+ and Cl-."
    solvent_ion1="Na+"
    solvent_ion2="Cl-"
fi

echo "Strip WAT and $solvent_ion1 and $solvent_ion2."
strip_string_solvent_ions=":$solvent_ion1:$solvent_ion2"

prefix=$ROOT_DIR
script_dir=$prefix/0structure/scripts
input_dir=$prefix/0structure/input
output_dir=$prefix/0structure/output
system_parm=$input_dir/system.parm7
mkdir -p $output_dir

# Copy the create_dry_prmtop_crd script to a temp file.
script_template=$script_dir/create_dry_prmtop_crd_template
script_file=$script_dir/create_dry_prmtop_crd

if [[ -f $script_file ]]; then
    echo "Removing existing create_dry_prmtop_crd script."
    rm -f $script_file
fi

if [[ -f $output_dir/system.dry.prmtop ]]; then
    echo "Dry system already exists."
    rm -f $output_dir/system.dry.prmtop
fi

if [[ -f $output_dir/system.dry.crd ]]; then
    echo "Dry system already exists."
    rm -f $output_dir/system.dry.crd
fi

cp $script_template $script_file

# Update create_dry_promtop_crd script with given trim area and files.
sed -i "s|loadRestrt|loadRestrt $prefix/0structure/input/system.rst7|" $script_file
sed -i '0,/strip/!s/strip/strip '"$strip_string_solvent_ions"'/' $script_file
sed -i "s|outparm|outparm $output_dir/system.dry.prmtop $output_dir/system.dry.crd|" $script_file
sed -i "s|ambpdb -p|ambpdb -p $output_dir/system.dry.prmtop|" $script_file
sed -i "s|-c|-c $output_dir/system.dry.crd|" $script_file
sed -i "s|>|> $output_dir/system.dry.pdb|" $script_file

cat $script_file

parmed -i $script_file -p $system_parm
ambpdb -p $output_dir/system.dry.prmtop -c $output_dir/system.dry.crd > $output_dir/system.dry.pdb