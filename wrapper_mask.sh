#!/bin/bash


# Wrapper script for GLM
main_folder=/.../


# Mask file
#mask_name=harvardoxford-subcortical_prob_Right_Hippocampus_30_bin

for mask_name in  "HC_left_ant" 
do 
mask_file=$main_folder/Masks/$mask_name.nii.gz

#create sub list with all subs in Mask folder
cd /.../.../.../.../.../


echo "paths" > "$main_folder"/Masks/registration_paths_"$mask_name".txt

for c_sub in 
do

  # Get subject code
  sub_code=sub-$c_sub
  echo "Starting $sub_code"

  for c_sess in 1 
  do

    # Get preproc main_folder
    
       preproc_folder=$main_folder/preproc_fmriprep/fmriprep
    

    # Build filenames
    out_image=$main_folder/Masks/$sub_code/ses-0$c_sess""/$sub_code""_space-native_roi-$mask_name""_mask.nii.gz

    #check ref-image versions
    cd $preproc_folder/$sub_code/ses-0"$c_sess"/func
    ref_im="$preproc_folder"/"$sub_code"/ses-0"$c_sess"/func/"$sub_code"_ses-0"$c_sess"_task-memokid_run-1_space-T1w_boldref.nii.gz
    
   
    #check trf-file version
    cd $preproc_folder/$sub_code/anat
           
    trf_file="$preproc_folder"/"$sub_code"/anat/"$sub_code"_acq-orig_from-MNI152NLin2009cAsym_to-T1w_mode-image_xfm.h5


    echo "ref_im" >> "$main_folder"/Masks/registration_paths_"$mask_name".txt
    echo $ref_im >> "$main_folder"/Masks/registration_paths_"$mask_name".txt
    echo "trf_file" >> "$main_folder"/Masks/registration_paths_"$mask_name".txt
    echo $trf_file >> "$main_folder"/Masks/registration_paths_"$mask_name".txt
    echo "out_image" >> "$main_folder"/Masks/registration_paths_"$mask_name".txt
    echo $out_image >> "$main_folder"/Masks/registration_paths_"$mask_name".txt
    
    cd /.../.../.../.../.../.../
    sh applyTransformation.sh $mask_file $ref_im $out_image $trf_file

    wait
    echo "Applied transformation for "$sub_code" in ses"$c_sess
    echo

    done
done

done

