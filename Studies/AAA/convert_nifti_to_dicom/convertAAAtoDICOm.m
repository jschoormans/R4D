% AAA NIFIT TO DICOM
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/nifti'))
addpath(genpath('/opt/amc/matlab/toolbox/MRecon/'))

%%
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Studies/AAA')
addpath('convert_nifti_to_dicom/')
load('filelocations.mat')
%%

disp('CONVERT FEM SCANS TO DICOM!')
warning('off','images:dicom_add_attr:invalidAttribChar')
warning('off','images:dicomwrite:inconsistentIODAndCreateModeOptions')

for jj=8:25
    try
        cd('/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/recons_29may/')
        
        %find nifti in recon folderr
        D=dir('*.nii');
        %     [FileNameNifti,PathNameNifti] = uigetfile('*.nii','choose nifti to convert');
        PathNameNifti='/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/recons_29may/'
        FileNameNifti=D(jj).name;
        
        
        % find dicom (from filelocations.mat)
        cd('/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/raw/dicom/')
        disp('2: choose raw data file that was used for recon')
        %     [FileNameRaw,PathNameRaw] = uigetfile('*.raw','choose raw file that was used for recon');
        
        scan_nr=str2num(FileNameNifti(6:7))
        session_nr=str2num(FileNameNifti(9:10))
        FileNameRaw=F{scan_nr,session_nr}.name
        PathNameRaw=F{scan_nr,session_nr}.path
        
        
        %find .dcm template of same scan...
        disp('3 : choose meta data template')
        FileList=dir(fullfile([PathNameRaw,'/../radian'],'**','MR/*3D_DCE*/*.dcm'))
        
        %     [FileNameTemplate,PathNameTemplate] = uigetfile('*.dcm','choose a dicom template');
        FileNameTemplate=FileList(1).name
        PathNameTemplate=FileList(1).folder
        
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
    catch
        disp('Error in converting jj')
    end
end