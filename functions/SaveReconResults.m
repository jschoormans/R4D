function [MR,P] = SaveReconResults(MR,P);


fprintf('filename=%s...\n',P.filename)
fprintf('Saving parameters to text file...\n');
% print parameter to text file

if strcmp(P.recontype,'3D')
fprintf('Saving NIFTI...\n')
%save to NIFTI
voxelsize=MR.Parameter.Scan.AcqVoxelSize;
nii=make_nii(abs(MR.Data),voxelsize,[],[],'');
save_nii(nii,strcat(P.filename,'.nii'))
end

diary(P.filename)
diary on 
P
P.CS
P.espiritoptions
P.reconslices
fprintf('Golden-angle Stack-of-Stars Finished!\n')
diary off
end