# prepT2space

Preparing 7T T2 SPACE data for further processing including alignment with T1w.

## Input Parameters
```
* input bids dir
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
