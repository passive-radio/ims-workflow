#!/bin/bash

if [[( -z $1 ) || ( -z $2 )]]; then
    echo "Please provide the residue number range to analyze."
    exit 1
fi

residue_beg=$1
residue_end=$2

if [[ -z $3 ]]; then
    cnt_systems=1
    echo "Assume the number of systems to analyze is 1."
else 
    cnt_systems=$3
fi

prefix=$ROOT_DIR
script_dir=$prefix/2equilibration/scripts
output_dir=$prefix/2equilibration/output/analysis
mkdir -p $output_dir

template_mdout_settings=$script_dir/cpptraj_mdout_template
tmeplate_rms_settings=$script_dir/cpptraj_rms_template

mdout_settings=$script_dir/cpptraj_mdout.in

echo "cpptraj job (mdout, rms) start time" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log

if [[ -e $mdout_settings ]]; then
    rm $mdout_settings
fi

sed -e "s|PREFIX|${prefix}|g" \
    -e "s|OUTPUT|${output_dir}|g" \
    -e "s|CNT_SYSTEMS|${cnt_systems}|g" \
    $template_mdout_settings > $mdout_settings

cpptraj -i $mdout_settings

for step in 1heat 2nvt 3npt;do
    rms_settings=$script_dir/cpptraj_rms_${step}.in
    if [[ -e $rms_settings ]]; then
        rm $rms_settings
    fi

    sed -e "s|PREFIX|${prefix}|g" \
        -e "s|OUTPUT|${output_dir}|g" \
        -e "s|CAL_TYPE|${step}|g" \
        -e "s|CNT_SYSTEMS|${cnt_systems}|g" \
        -e "s|RESIDUE_BEG-RESIDUE_END|${residue_beg}-${residue_end}|g" \
        $tmeplate_rms_settings > $rms_settings

    cpptraj -i $rms_settings
done

echo "cpptraj job (mdout, rms) end time  :" `date +'%Y%m%d %H:%M:%S'` >> $output_dir/time.log