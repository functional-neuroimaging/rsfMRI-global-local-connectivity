#!/bin/bash

# This script carries out unpaired t-test of global or local connectivity maps. 
#
# GroupA and groupB are the group names (for example: KO and WT) and they have 
# to be part of the the filenames. If you set groupA to experimental group and
# groupB to control group (highly recommended) then positive values would mean 
# hyper-connectivity in the experimental group with respect to control group. 
# Accordingly, negative values would mean hypo-connectivity in the experimental 
# group with respect to control group. 
#
# The main output of the code is the group_Tstat.nii.gz that is the result of
# unpaired t-test. This code also outputs one sample Tstat.nii.gz and mean.nii.gz
# for each group.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2017)
# -----------------------------------------------------------


groupA=KO # edit this
groupB=WT # edit this

connectivity_maps_path=$PWD/01_gbcmaps/ # edit this, path of single subject connectivity maps
two_sample=$PWD/02_t-test/ # edit this, path of results of t-tests

mkdir $two_sample

    3dttest++ \
        -setA $connectivity_maps_path/*_${groupA}_*.nii.gz \
        -setB $connectivity_maps_path/*_${groupB}_*.nii.gz \
        -prefix $two_sample/stats.nii.gz

    3dcalc \
        -a $two_sample/stats.nii.gz"[0]" \
        -expr "a" \
        -prefix $two_sample/stats_${groupA}_vs_${groupB}_group_mean_diff.nii.gz

    3dcalc \
        -a $two_sample/stats.nii.gz"[1]" \
        -expr "a" \
        -prefix $two_sample/stats_${groupA}_vs_${groupB}_group_Tstat.nii.gz

    3dcalc \
        -a $two_sample/stats.nii.gz"[2]" \
        -expr "a" \
        -prefix $two_sample/stats_${groupA}_mean.nii.gz

    3dcalc \
        -a $two_sample/stats.nii.gz"[3]" \
        -expr "a" \
        -prefix $two_sample/stats_${groupA}_Tstat.nii.gz

    3dcalc \
        -a $two_sample/stats.nii.gz"[4]" \
        -expr "a" \
        -prefix $two_sample/stats_${groupB}_mean.nii.gz

    3dcalc \
        -a $two_sample/stats.nii.gz"[5]" \
        -expr "a" \
        -prefix $two_sample/stats_${groupB}_Tstat.nii.gz


rm $two_sample/stats.nii.gz

