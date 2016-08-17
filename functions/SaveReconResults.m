function [MR,P] = SaveReconResults(MR,P);

fprintf('filename=%s...\n',P.filename)
fprintf('Saving parameters to text file...\n');
% print parameter to text file
CellData=struct2cell(P); %used to print all settings to textfile
fileID=fopen([P.filename,'.txt'],'w');
% fprintf(fileID,'%s \n',CellData{1,:})
fprintf(fileID,'TO DO: fix printing of parameters to text file');
fclose(fileID);

fprintf('Saving NIFTI...\n')
%save to NIFTI
voxelsize=MR.Parameter.Scan.AcqVoxelSize;
nii=make_nii(abs(MR.Data),voxelsize,[],[],'');
save_nii(nii,strcat(P.filename,'.nii'))
fprintf('Golden-angle Stack-of-Stars Finished!\n')

end