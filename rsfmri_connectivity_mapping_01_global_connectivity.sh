#!/bin/bash
#
# This script calculates global (long-range) connectivity i.e. mean voxelwise 
# functional connectivity (Pearson's R) between each voxel and all the other 
# voxels in the brain. This metric is also known as weighted degree centrality 
# (Cole et al. NImage2009)
# https://www.sciencedirect.com/science/article/pii/S1053811909011616
#
# Practical info:
#
#   1) use bash script 01_rsfmri_global_connectivity.sh to calculate global 
#      connectivity at the voxel level for each subject of the study.
# 
#   2) then use 02_group_two_sample.sh to calculate one and two sample t-tests.
# 
#   3) copy and paste dcbc.py to your working directory, as that is the code 
#      that does the actual calculation (written by Adam Liska). Make sure 
#      you have installed all the python modules needed before starting.
#
# The all thing is fully automatized and relatively fast. All you need to do 
# is to edit the bash scripts and provide:
# 
#   - the number of CPU ("numjobs") you want to use - this is the number of 
#     subjects you want to analyze simultaneously 
#     (https://www.gnu.org/software/parallel/)
# 
#   - the path of the folder of your preprocessed data ("path_smoothed_ts").
# 
#   - the brainmask you use for the study with full path ("mask.nii.gz")
# 
# To make you life easy, I added "# edit_this" here and there, 
# then you know where to edit. 
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2017)
# -----------------------------------------------------------

numjobs=7

path_smoothed_ts=/path/to/smoothed/ts/ # edit this

function globalconn {

    ts=$1
    mask=/home/imaging/config/scripts/restingstate_scripts/chd8_functional_template_mask_wo_cerebellum.nii.gz # edit this
    outdir=01_gbcmaps

    name=$(basename $ts .nii.gz)
    python -u dcbc.py \
        -m $mask \
        -o $outdir/${name}_globalconn.nii.gz \
        $ts

}
export -f globalconn


# main starts here
mkdir 01_gbcmaps

echo $path_smoothed_ts/ag*_smoothed.nii.gz | tr " " "\n" > list.txt # edit this
parallel \
    -j $numjobs \
    globalconn {} \
    < list.txt
