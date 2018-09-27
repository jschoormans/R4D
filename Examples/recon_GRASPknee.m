
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
    P.folder='L:\basic\divi\Ima\parrec\Jasper\dce_knee_26_9_2018\'
else
    P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/Jasper/dce_knee_26_9_2018/'
    %     P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/Pauldh/2018-09-04_DCE_knie_grasp/'
end
% P.file='re_04092018_1824564_18_2_dyn_grasp_hq3_spirV4.raw'
% P.sense_ref='re_04092018_1730430_1000_5_coilsurveyscanV4.raw'
% P.coil_survey='re_04092018_1738208_1000_11_senserefscanV4.raw' %switched

% P.file='dc_26092018_1615266_7_2_ga_old_examcard_1x1x2V4.raw'
% P.file='dc_26092018_1623518_9_2_ga_old_ctrparamoff-senseoffV4.raw'
% P.file='dc_26092018_1626246_10_2_ga_old_sense1V4.raw'
P.file='dc_26092018_1620343_8_2_ga_old_sense1V4.raw'

P.coil_survey='dc_26092018_1608153_1000_2_coilsurveyscanV4.raw'
P.sense_ref='dc_26092018_1610031_1000_5_senserefscanV4.raw' 

P.binparams.visualize =1;
% P.spokestoread=[0:300]';
% P.reconslices=[9:20]

P.resultsfolder=[P.folder,'Results'];
P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='sense2' % 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5

P.enableTGV=1
P.GPU=0

[MR,P]=GoldenAngle(P)

