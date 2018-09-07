asl_file --data=MONROE-x-207978-x-207978-x-901-d0030.nii.gz --ntis=1 --iaf=ct --diff --out=diffdata --mean=diffdata_mean
bet struct/207295_301_questionable_T1W_3D_TFE.nii struct_brain
oxford_asl -i diffdata -o perfusion --artsupp --tis 3.3 --bolus 1.65 --casl -c asl_calib/label/label.nii -s struct_brain.nii.gz

rsync -avz --dry-run --verbose --include='Analysis/' --exclude='*BOLD*' --exclude='NIFTI' --exclude='Jobs' --exclude='PARREC' --exclude='Raw*' --exclude='Resting*' --exclude='*.dcm' --exclude='DTI' --exclude='Flair' --exclude='Struc*' --exclude='Survey' --exclude='ASL' /Volumes/ioSafe/monroe/Research_Data/R21_Subject_Data/ASDM/ /Users/atalla.3/Desktop/R21PSC/
rsync -avz --dry-run --verbose --exclude'*' --include='Analysis/' /Volumes/ioSafe/monroe/Research_Data/R21_Subject_Data/ASDM/ /Users/atalla.3/Desktop/R21PSC/