% accelerated dynamic radial contrast enhanced scans of abdominal aortic
% aneurysm data
% recon code - Jasper Schoormans 2019
% jasper.schoormans@gmail.com

%%%%%%%%%%%%%%%%%%%%% add relevant folders
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))
addpath(genpath('/opt/amc/matlab/toolbox/MRecon/'))
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% Load file locations
clear
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Studies/AAA')
load('filelocations.mat') %filenames an dpaths of AAA DCE scans --> of note. A few sessions seem to have two DCE scans - ask what's up with that
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% LOOP OVER OPTIONS/SCANS
for study_nr=1:20
    for session_nr=1
        for lambdafac=[10]
            
            % specify DCE recon options
            P=struct();
            P.folder=[F{study_nr,session_nr}.path,filesep];
            P.file=F{study_nr,session_nr}.name;
            P.resultsfolder='/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/recons_29may';
            
            P.recontype='DCE-2D';
            P.DCEparams.nspokes=34; 
            P.DCEparams.display=1;
            P.sensitvitymapscalc='openadapt';
            P.channelcompression=true;
            P.cc_nrofchans=5;
%             P.reconslices=(20);
            P.zerofill=0; % save zero-filled nii (double recon res.)
            
            P.DCEparams.Beta='FR';
            P.DCEparams.nite=8; % should be 8
            P.DCEparams.outeriter=4;
            P.DCEparams.display=1;
            P.DCEparams.lambdafactor=lambdafac;
            P.DCEparams.enableTGV=0;
            
            P.filename=['AAA_B',num2str(study_nr,'%4.2d'),'_',num2str(session_nr,'%4.2d'),'_lambda',num2str(P.DCEparams.lambdafactor,'%4.2d'),...
                '_',num2str(P.DCEparams.nspokes),'spokes'];

            P.GPU=1;
            
            MR=GoldenAngle(P);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%
