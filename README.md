# prepT2space

Preparing 7T T2 SPACE data for further processing.

The initial version relies on output brainmask from fmriprep, which at this point is not optimized for 7T data and is thus imperfect. As a temporary solution, this mask is dilated to allow rough T2w masking for bias field correction and registration purposes. Future extensions will involve optimizing brainmasking.

## Input Parameters
```
* input bids dir
* input fmriprep dir
* output derivatives dir
```

## Output File Structure
```
<prepT2space-0.0.1>/
  sub-<participant_label>/
    anat/
      sub-<participant_label>_acq-SPACE_rec-DIS3D_run-01_T2w_preproc.nii.gz
      sub-<participant_label>_acq-SPACE_rec-DIS3D_run-01_T2w_preproc_brain.nii.gz
      sub-<participant_label>_acq-SPACE_rec-DIS3D_run-01_T2w_preproc_space-T1w.nii.gz
      sub-<participant_label>_acq-SPACE_rec-DIS3D_run-01_T2w_preproc_space-T1w_brain.nii.gz
```
