
if ispc()
    addpath(genpath('L:\basic\divi\Projects\cosart\Matlab\R4D\General_Code'))
    addpath(genpath('L:\basic\divi\Projects\cosart\Matlab\R4D\OtherToolboxes'))
else %linux
    addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
    addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
    setenv('TOOLBOX_PATH','/opt/amc/bart-0.4.01/bin/')
end

%% MRECON VERSION
addpath(genpath('/opt/amc/matlab/toolbox/MRecon-3.0.556/'))

%%
clear all; close all; clc;

P=struct
if ispc()
    P.folder='L:\basic\divi\Projects\target\mri\recon\2017_10_31_TARGET-01\TA_154472\' %TARGET01
else
    P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2017_10_31_TARGET-01/TA_154472/'
    P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_01_08_TARGET-02/2018_01_08/TA_238210/' %TARGET 002
end
% P.file='ta_31102017_1859312_7_2_wip_3d_dce_tra_1-2mmV4.raw' #target 01 


P.file='ta_08012018_1859329_8_2_wip_3d_dce_tra_1-2mmV4.raw' 

P.coil_survey='ta_08012018_1824030_1000_2_coilsurveyscanV4.raw'
P.sense_ref='ta_08012018_1833035_1000_10_senserefscanV4.raw' 

P.binparams.visualize =1;
P.spokestoread=[0:500]';
P.reconslices=[10:20]

P.resultsfolder=[P.folder,'ResultsNew'];
P.filename=['tagret2_openadapt_34sp_500']
P.recontype='DCE'
P.DCEparams.nspokes=34; %34 %(2,3,5,8,13,21,34,...)
P.DCEparams.display=1;
P.sensitvitymapscalc='openadapt' % sense2 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5

P.enableTGV=1
P.GPU=0
P.prewhiten=0

P.saveMR=0
P.reloadMR=0
P.clearcorr=1

%%

[MR,P]=GoldenAngle(P)

