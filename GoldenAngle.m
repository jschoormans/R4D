function [MR,P] = GoldenAngle(varargin);
% JASPER SCHOORMANS JULY 2016

%CITE RELEVANT PAPERS
%EDDY CURRENT CORRECTION:
%XD-GRASP: 
%BART TOOLBOX:

%input parameters (optional): 
% P.folder              %full path of folder where raw files are located (include /)
% P.file                %filename of .raw file
% P.resultsfolder       %full path of folder where results should be saved
% P.coil_survey         %filename of coil_survey file
% P.sense_ref           %filename of sense_ref file
% 
% P.recontype           %'3D'; 'DCE'; '4D' ; '5D'(multiple echoes)  (standard:3D)
% 
% P.sensitivitymaps     %1/0 use of sense maps for coil combinations
% P.sensitvitymapscalc  %way of calculating sensitivity maps: sense (standard)/espirit
% P.dynamicespirit      %true(4D)/false(3D) (TO DO put in espiritoptions!)
% P.espiritoptions.nmaps %number of maps to compute and use
% 
% P.channelcompression  %true/false: standard false
% P.cc_nrofchans        %number of channels used for compression
% P.spokestoread        %vector specifiying channel numbers to use (standard:all)
% P.channelstoread      %vector specifying spokes to read (standard:all)
% P.reconresolution     %vector of matrix size (x,y,z)
% P.reconslices=[vector] %vector of slices to reconstruct (1 to max)
% empty=all slices (only for 4D and 5D)
% P.CS.iter
% P.CS.reg



% P.binparams           %structure of parameters to use for binning (see
% ksp2frames)


% TO DO IN FUTURE (IDEAS)
% P.DCEsettings %settings for DCE recons
% k-space shift correction
% whats up with sense maps in 3D Gyrotools gridding?
% BART nufft/ Fessler NUFFT for 3D?
% make sure that orientations are correct
% P.CS settings 
% tryto add weights to bart CS
% Remove slice oversampling 
% maybe build in DCE in 4D part instead of into NUFFT?
% add interpolation to finer resolution in last step
% m2 binning
% automatic coil selection (remove noise-only coils robustly)

disp('--------------------------------------------------------------')
disp(' _____       _     _             ___              _      ')
disp('|  __ \     | |   | |           / _ \            | |     ')
disp('| |  \/ ___ | | __| | ___ _ __ / /_\ \_ __   __ _| | ___ ')
disp('| | __ / _ \| |/ _` |/ _ \ |_ \|  _  | |_ \ / _` | |/ _ \')
disp('| |_\ \ (_) | | (_| |  __/ | | | | | | | | | (_| | |  __/')
disp(' \____/\___/|_|\__,_|\___|_| |_\_| |_/_| |_|\__, |_|\___|')
disp('                                             __/ |       ')
disp('                                            |___/        ')
fprintf ('Golden-angle stack-of-stars reconstruction\n')
fprintf('V1.0\n\n')
fprintf('J Schoormans - AMC Amsterdam - July 2016\n')
disp('--------------------------------------------------------------')
tic

if nargin==0
    P=struct;
    fprintf('Warning: no settings provided.\n Continuing recon...\n');
else nargin==1;
    P=varargin{1};
end

P=checkGAParams(P);
switch P.recontype
    case '4D';  disp('4D reconstruction');
        [MR,P]=FullRecon_SoS_4D(P);
    case 'DCE'; disp('DCE reconstruction (not yet implemented...');
        [MR,P]=FullRecon_SoS_DCE(P);
    case '5D';  disp('5D reconstruction (multiple echoes)');
        [MR,P]=FullRecon_SoS_5D(P);
    case '3D';  disp('Performing full 3D golden angle stack-of-stars reconstruction...');
        [MR,P]=FullRecon_SoS_3D(P);
end

[MR,P] = SaveReconResults(MR,P);
toc
disp('--------------------------------------------------------------')

end
