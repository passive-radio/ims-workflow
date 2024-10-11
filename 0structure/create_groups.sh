#!bin/bash

# This script creates a set of groups for CURP computation.

echo "This script creates a set of groups for CURP computation."

prefix=$ROOT_DIR
script_dir=$prefix/0structure/scripts
input_dir=$prefix/0structure/input
output_dir=$prefix/0structure/output
system_parm=$input_dir/system.parm7
mkdir -p $output_dir

cpptraj_commands_template=$script_dir/atominfo_template.cpptraj
cpptraj_commands=$script_dir/atominfo.cpptraj

prmtop_file=$output_dir/system.dry.prmtop
atominfo_output=$output_dir/atominfo.dat

if [[ -f $cpptraj_commands ]]; then
    echo "Removing existing atominfo.cpptraj."
    rm -f $cpptraj_commands
fi

cp $cpptraj_commands_template $cpptraj_commands

# Update atominfo.cpptraj script with given files.
sed -i "s|PRMTOP_FILE|$prmtop_file|" $cpptraj_commands
sed -i "s|ATOMINFO_FILE|$atominfo_output|" $cpptraj_commands


cpptraj -i $cpptraj_commands

python3 $script_dir/generate_atomgroup_sidechain.py \
    --sidechain-filename $output_dir/atomgroup_side.dat \
    --residue-filename $output_dir/atomgroup_residue.dat \
    --atominfo-filename $output_dir/atominfo.dat

# If you want to group up the all member atoms of a peptide (sidechain and backbone) into a single group,
# You can tell the script which residue ids to group into a single group.
# For example, if you want to group up these members of residue 1, 2 into these same groups:

# python3 $script_dir/generate_atomgroup_sidechain.py \
#     --sidechain-filename $output_dir/atomgroup_side.dat \
#     --residue-filename $output_dir/atomgroup_residue.dat \
#     --atominfo-filename $output_dir/atominfo.dat \
#     --no-separated-residues 1 2