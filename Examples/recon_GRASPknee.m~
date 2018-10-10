
if ispc()
    addpath(genpath('L:\basic\divi\Projects\cosart\Matlab\R4D\General_Code'))
    addpath(genpath('L:\basic\divi\Projects\cosart\Matlab\R4D\OtherToolboxes'))
else %linux
    addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
    addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
    
end

%% MRECON VERSION
addpath(genpath('/opt/amc/matlab/toolbox/MRecon-3.0.556/'))

%%
clear all; close all; clc;

P=struct
if ispc()
    %     P.folder='L:\basic\divi\Ima\parrec\Pauldh\2018-09-04_DCE_knie_grasp\'
%     P.folder='L:\basic\divi\Ima\parrec\Jasper\dce_knee_26_9_2018\'
else
%     P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/Jasper/dce_knee_26_9_2018/'
    %     P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/Pauldh/2018-09-04_DCE_knie_grasp/'
    P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/Jasper/DCE_KNEE 02_10_2018/'
end
% P.file='gr_02102018_1025400_4_2_old_1x1x2_300pctV4.raw'
% P.file='gr_02102018_1027564_5_2_dyn_grasp_hq3_spirV4.raw'
P.file='gr_02102018_1030066_6_2_old_1x1x2_300pct_fa30V4.raw'
% P.file='gr_02102018_1032173_7_2_old_1x1x2_300pct_fa30_0.8V4.raw'
% P.file='gr_02102018_1035155_8_2_old_1x1x2_300pct_fa30_tfe35V4.raw'
% P.file='gr_02102018_1037174_9_2_old_1x1x2_300pct_fa30_tfe35_0.8V4.raw'

% P.file='gr_02102018_1044407_10_2_old_1x1x2_300pct_fa30V4.raw'
% P.sense_ref='gr_02102018_1020496_1000_5_senserefscanV4.raw'
P.sense_ref='gr_02102018_1044162_1000_8_senserefscanV4.raw'
P.coil_survey='gr_02102018_1019084_1000_2_coilsurveyscanV4.raw'


P.binparams.visualize =1;
% P.spokestoread=[0:300]';
P.reconslices=[9:20]

P.resultsfolder=[P.folder,'Results'];
P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='sense' % 
P.channelcompression=false;
P.cc_nrofchans=6;
P.filename='scan6_sense'

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5

P.enableTGV=1
P.GPU=0

[MR,P]=GoldenAngle(P)

