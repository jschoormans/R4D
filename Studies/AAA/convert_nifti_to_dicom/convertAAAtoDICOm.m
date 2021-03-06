% AAA NIFIT TO DICOM
%tested with Matlab-R2018a

addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/nifti'))
addpath(genpath('/opt/amc/matlab/toolbox/MRecon/'))

%%
cd('/scratch/jschoormans/R4D/General_Code/Studies/AAA')
addpath('convert_nifti_to_dicom/')
load('filelocations.mat')
%%
cd('/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/recons_29may/')
delete('dicom_conversion.txt')
diary 'dicom_conversion.txt'


disp('CONVERT FEM SCANS TO DICOM!')
warning('off','images:dicom_add_attr:invalidAttribChar')
warning('off','images:dicomwrite:inconsistentIODAndCreateModeOptions')

for jj=1:100
    fprintf('Converting %d \n',jj);
    try
        cd('/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/recons_29may/')
        
        %find nifti in recon folderr
        D=dir('*.nii');
        %     [FileNameNifti,PathNameNifti] = uigetfile('*.nii','choose nifti to convert');
        PathNameNifti='/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/recons_29may/';
        FileNameNifti=D(jj).name;;
        
        
        % find dicom (from filelocations.mat)
        cd('/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/raw/dicom/')
        %     [FileNameRaw,PathNameRaw] = uigetfile('*.raw','choose raw file that was used for recon');
        
        scan_nr=str2num(FileNameNifti(6:7));
        session_nr=str2num(FileNameNifti(9:10));
        FileNameRaw=F{scan_nr,session_nr}.name;
        PathNameRaw=F{scan_nr,session_nr}.path;
        
        
        %find .dcm template of same scan...
        
        % ugly code... not same list in all folders..
        FileList=dir(fullfile(extractBefore(PathNameRaw,'/GtpacknGo'),'**','MR/*3D_DCE*/*.dcm'));
        
        FileNameTemplate=FileList(1).name;
        PathNameTemplate=FileList(1).folder;
        
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
        
        if ~isdir([PathNameNifti,resultsfoldername])
            
            mkdir(PathNameNifti,resultsfoldername)
            
            disp('ready to convert: press a key to continue');% pause;
            disp('starting...')
            %         toDicom_jan19(I,metadata,MR,timeresolution,resultsfolder)
            toDicom_jul19(I,metadata,MR,timeresolution,resultsfolder)
            
            disp('Finished!')
        else
            fprintf('%s: Already converted \n',resultsfoldername)
        end
        
        
    catch
        fprintf('Error in converting %d\n',jj)
    end
    
end

diary off