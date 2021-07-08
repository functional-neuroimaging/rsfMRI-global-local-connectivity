#!/bin/bash

tval=$1 
pval=$2 
brainmask=$3
shift 3
tmapset=$*

PARAMETERS=$#

if [ $PARAMETERS -lt 1 ];
then
echo
echo " This script calculates cluster correction after a voxel tresholding at specified t (or z) "
echo
echo " Usage: cluster_correction_FSL_parallel.sh <t_thresh_height> <p_val_clust> /path/template_mask.nii.gz *t-maps.nii.gz "
echo
echo " Where "
echo	" - t_thresh_height is the desired t threshold at the voxel level, usually 2 (p=0.95 two-tailed) "
echo	" - p_val_clust is the desired cluster probability, usually 0.05 or 0.01 "
echo
echo " Script orginally shared by Adam Schwarz "
echo " and polished by Marco Pagani "
echo " Functional Neuroimaging Lab "
echo " Istituto Italiano di Tecnologia, Rovereto "
echo " (2017) "
exit 
fi

for sub in $tmapset; do

  echo "$sub"
  stub=`basename "$sub" .nii.gz`


  # work out the smoothness
  smoothest -z "$sub" -m $brainmask > rm.smth.txt
  for (( i=1 ; i<2 ; i++ )) do
    read LINE
    dlhval=`echo $LINE | awk '{print $2}'`
    read LINE
    volval=`echo $LINE | awk '{print $2}'`
  done < rm.smth.txt

  echo "Smoothness = $dlhval"
  echo "Volume = $volval"

  ## get cluster stats for positive correlations
  ccimg_pos=rm.cc_pos

  cluster -i $sub \
          -t $tval \
          -p $pval \
          --volume=$volval \
          --dlh=$dlhval \
          --peakdist=2 \
          --othresh=$ccimg_pos \
          --mm \
          --minclustersize

  ## get cluster stats for negative correlations
  ccimg_neg=rm.cc_neg

  fslmaths "$sub" -mul -1 rm.tmap.reversed.nii

  cluster -i rm.tmap.reversed.nii \
          -t $tval \
          -p $pval \
          --volume=$volval \
          --dlh=$dlhval \
          --peakdist=2 \
          --othresh=$ccimg_neg \
          --mm \
          --minclustersize

  ## stitch the cc positive and negative images together
  ccimg="$stub"_cc_t"$tval"_p"$pval"
  fslmaths $ccimg_neg -mul -1 -add $ccimg_pos $ccimg

  rm rm.*

done

exit
