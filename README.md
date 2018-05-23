# prepT2space

Preparing 7T T2 SPACE data for further processing including alignment with T1w.

## Input Parameters
```
* input bids dir
* output derivatives dir
```

## Output File Structure
```
<prepT2space-0.0.1b>/
  sub-<participant_label>/
    anat/
      sub-<participant_label>_acq-SPACE_T1w_brain.nii.gz
      sub-<participant_label>_acq-SPACE_T1w_brainmask.nii.gz
      
      sub-<participant_label>_acq-SPACE_T2w_preproc.nii.gz
      sub-<participant_label>_acq-SPACE_T2w_preproc_space-T1w.nii.gz
      sub-<participant_label>_acq-SPACE_T2w_preproc_target-T1w_affine.mat
```

## Running on Graham
```
# for multiple subjects (runs for all subjects in a participants.tsv file)
bidsBatch prepT2space_v0.0.1d /project/6007967/cfmm-bids/Khan/SNSX_7T/derivatives/gradcorrect_0.0.1h/ /project/6007967/jclau/SNSX_7T/derivatives/single_subject_test/ participant

# for a single subject (note: -s has to be right after bidsBatch call for now)
bidsBatch -s C016 prepT2space_v0.0.1d /project/6007967/cfmm-bids/Khan/SNSX_7T/derivatives/gradcorrect_0.0.1h/ /project/6007967/jclau/SNSX_7T/derivatives/single_subject_test/ participant
```
