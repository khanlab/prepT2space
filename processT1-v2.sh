#!/bin/bash

# This file records the processing parameters for 7T DBS dataset
# Remember to put absolute path of the files for processing

function usage {

echo "
Usage:
  process.sh <T1w_image.nii> <T2w_image.nii> <output_path> <work_directory> <output_basename>
  The script process T1w & T2w MRIs of 7T data for purposes.
  All images should be distortion corrected.
  Put absoluate path for files to be processed
"

}

set -e

T1="$1"
T2="$2"
output_path="$3"
work_directory="$4"
basename="$5"


if [ $# -ne 5 ]
then
  usage;
  exit 1;
fi

if [ ! -f $T1 ] || [ ! -f $T2 ] || [ ! -d $output_path ] || [ ! -d $work_directory ]
then
  echo "one of the input/path was not provided or does not exist"
  exit 1;
fi


cd $work_directory

# Brain mask estimation with T1w and generate masked image
echo "Step 1. Brain maks estimation with bet2"
N4BiasFieldCorrection -d 3 -b [200] -s 4 -c [600x400x300x200x20,0] -i $T1 -o $basename-T1.nii.gz -v
fsl5.0-bet2 $basename-T1.nii.gz $basename-T1-bet -f 0.15 -w 1.1 -m

# Rough inhomogeneity correction for T2w
echo "Step 2. Rough N4 inhomogeneity correction for T2w MRI"
N4BiasFieldCorrection -d 3 -b [200] -s 4 -c [600x400x300x200x20,0] -i $T2 -o $basename-T2-Nu1.nii.gz -v

# Register T1 to T2 MRI
echo "Step 3. Register T1 to T2 MRI"
fsl5.0-flirt -ref $basename-T2-Nu1.nii.gz -out $basename-T1-to-T2.nii.gz -in $basename-T1.nii.gz  -omat $basename-T1-to-T2.mat -dof 6 -cost normmi
fsl5.0-flirt -ref $basename-T2-Nu1.nii.gz -out $basename-T1-to-T2-mask.nii.gz -in $basename-T1-bet_mask.nii.gz -init $basename-T1-to-T2.mat -interp nearestneighbour -applyxfm
# Process the masks
ImageMath 3 $basename-T1-bet_mask-D.nii.gz MD $basename-T1-to-T2-mask.nii.gz 4
ImageMath 3 $basename-T1-bet_mask-D_blur.nii.gz G $basename-T1-bet_mask-D.nii.gz 1

# combine the T2 and transformed T1 image
echo "Step 4. Combining T2w MRI and transformed T1w MRI for N4 correction"
ImageMath 3 $basename-T1-T2-comb.nii.gz m $basename-T1-to-T2.nii.gz $T2
ImageMath 3 $basename-T1-T2-comb-scale.nii.gz / $basename-T1-T2-comb.nii.gz 4000
N4BiasFieldCorrection -d 3 -i $basename-T1-T2-comb-scale.nii.gz -o [$basename-T1-T2-comb-N4.nii.gz,$basename-T2-biasfield.nii.gz] -b [250] -r 0 -s 4 -c [600x500x500x400x200,1e-5] -v -x $basename-T1-bet_mask-D.nii.gz

#Convert T1w and T2w to MINC format, and denoise T2w MRI
echo "Step 5. Nonlocal-means denoise for T2w MRI"
nii2mnc $T2 $basename-T2.mnc
mincnlm $basename-T2.mnc $basename-T2-denoise-copy.mnc
mnc2nii -short -nii $basename-T2-denoise-copy.mnc $basename-T2-denoise.nii

# apply inhomogeneity field
echo "Step 6. Apply obtained inohomogeneity field to denoised T2w MRI"
ImageMath 3 $basename-T2-N4.nii.gz / $basename-T2-denoise.nii $basename-T2-biasfield.nii.gz

# redo image registration T2 to T1
echo "Step 7. Refine T2w to T1w rigid registration with processed images"
fsl5.0-flirt -in $basename-T2-N4.nii.gz -ref $basename-T1-bet.nii.gz -omat $basename-T2_to_T1.mat -dof 6 -cost normmi
fsl5.0-flirt -in $basename-T2-N4.nii.gz -out $basename-T2-to-T1-proc1.nii.gz -ref $T1 -init $basename-T2_to_T1.mat -interp spline -noclamp -applyxfm
fsl5.0-flirt -in $basename-T2-N4.nii.gz -out $basename-T2-to-T1-proc2.nii.gz -ref $T1 -init $basename-T2_to_T1.mat -noclamp -applyxfm

nii2mnc $basename-T2-to-T1-proc1.nii.gz $basename-T2-to-T1-proc1-copy.mnc
nii2mnc $basename-T2-to-T1-proc2.nii.gz $basename-T2-to-T1-proc2-copy.mnc
minccalc -expr "A[0]>=0?A[0]:A[1]" $basename-T2-to-T1-proc1-copy.mnc $basename-T2-to-T1-proc2-copy.mnc $basename-T2-to-T1-proc.mnc -short
mnc2nii -short -nii $basename-T2-to-T1-proc.mnc $basename-T2-to-T1-proc.nii
gzip -f $basename-T2-to-T1-proc.nii

#copy original T1 to the output folders
echo "Step 8. Move processing results to output folder and clean up"
yes | cp -rf $basename-T1.nii.gz $output_path/$basename'_'N4_T1w.nii.gz
yes | cp -rf $basename-T2-to-T1-proc.nii.gz $output_path/$basename'_'denoiseN4reg2T1w_T2w.nii.gz
yes | cp -rf $basename-T2-N4.nii.gz $output_path/$basename'_'denoiseN4_T2w.nii.gz
yes | cp -rf $basename-T2_to_T1.mat $output_path/$basename'_'T2toT1_rigid_xfm.mat
yes | cp -rf $basename-T1-bet_mask.nii.gz $output_path/$basename'_'T1bet2_brainmask.nii.gz
yes | cp -rf $basename-T2-biasfield.nii.gz $output_path/$basename'_'T2_N4biasfield.nii.gz

#clean up,flagging removing the entire work_directory or not
rm $basename-T1.nii.gz  $basename-T2-to-T1-proc.nii.gz $basename-T2-N4.nii.gz  $basename-T2_to_T1.mat $basename-T1-bet_mask.nii.gz $basename-T1-bet_mask.nii.gz $basename-T2-biasfield.nii.gz
rm $basename-T2-to-T1-proc1.nii.gz $basename-T2-to-T1-proc2.nii.gz $basename-T2-to-T1-proc.mnc $basename-T2-to-T1-proc1-copy.mnc $basename-T2-to-T1-proc2-copy.mnc

cd -

exit 0
