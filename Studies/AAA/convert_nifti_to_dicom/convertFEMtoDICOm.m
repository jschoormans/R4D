% AAA NIFIT TO DICOM 
addpath(genpath('L:\basic\divi\Projects\cosart\Matlab_Collection\nifti'))

disp('CONVERT FEM SCANS TO DICOM!')
warning('off','images:dicom_add_attr:invalidAttribChar')
warning('off','images:dicomwrite:inconsistentIODAndCreateModeOptions')

% cd('/home/jschoormans/lood_storage/divi/Projects/femoral/recons_final')
cd('L:\basic\divi\Projects\target\mri\recon')
disp('step 1: choose nifti')
[FileNameNifti,PathNameNifti] = uigetfile('*.nii','choose nifti to convert');

% cd('/home/jschoormans/lood_storage/divi/Ima/parrec/Jasper/Reconstructions/FEM')
cd('L:\basic\divi\Projects\target\mri\recon')
disp('2: choose raw data file that was used for recon')
[FileNameRaw,PathNameRaw] = uigetfile('*.raw','choose raw file that was used for recon');


% cd('/home/jschoormans/lood_storage/divi/Projects/femoral');
cd('L:\basic\divi\Projects\target\mri\raw\dicom\')
disp('3 : choose meta data template')
[FileNameTemplate,PathNameTemplate] = uigetfile('*.dcm','choose a dicom template');


%%
cd(PathNameTemplate);
metadata = dicominfo(FileNameTemplate);

cd(PathNameRaw);
MR=MRecon(FileNameRaw); %MRecon of same scan!!

cd(PathNameNifti);
X=load_nii(FileNameNifti);

%%
I=rot90(X.img,3); 
timeresolution=12.269876335991754;  %to do - calculate

resultsfoldername=strtok(FileNameNifti,'.');
resultsfolder=[PathNameNifti,resultsfoldername,'/'];
mkdir(PathNameNifti,resultsfoldername)

disp('ready to convert: press a key to continue');% pause; 
disp('starting...')
toDicom_jan19(I,metadata,MR,timeresolution,resultsfolder)

disp('Finished!')