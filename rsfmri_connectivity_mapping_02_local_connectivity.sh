#!/bin/bash
#
# This script calculates local connectivity i.e. mean voxelwise functional 
# connectivity between each voxel and all the voxels within a specific radius.
#
# Here the radius is set to 600um*10=6mm
#
# As for global connectivity, copy-paste dcbc.py to the forlder 
# where you use this code
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2017)
# -----------------------------------------------------------


numjobs=7

path_smoothed_ts=/path/to/smoothed/ts/

function localconn {

    ts=$1
    mask=/home/imaging/config/scripts/restingstate_scripts/chd8_functional_template_mask_wo_cerebellum.nii.gz #edit this
    outdir=01_lbcmaps

    name=$(basename $ts .nii.gz)
    python -u dcbc.py \
        -m $mask \
        -o $outdir/${name}_localconn.nii.gz \
	-r -6 \
        $ts

}
export -f localconn


# main starts here

mkdir 01_lbcmaps

echo $path_smoothed_ts/ag*_smoothed.nii.gz | tr " " "\n" > list.txt
parallel \
    -j $numjobs \
    localconn {} \
    < list.txt
