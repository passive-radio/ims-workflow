#!bin/bash

# Run all scripts in the 0structure directory.

prefix=$ROOT_DIR
workflow_dir=$prefix/0structure

bash $workflow_dir/tidy_system.sh &
wait
bash $workflow_dir/dry_system.sh &
wait
bash $workflow_dir/create_groups.sh