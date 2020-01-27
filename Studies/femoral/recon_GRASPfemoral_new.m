
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
    P.folder='L:\basic\divi\Projects\femoral\FEM\FEM10_01\'
else
    P.folder='/home/jschoormans/lood_storage/divi/Projects/femoral/FEM/FEM10_01/'
    %     P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/Pauldh/2018-09-04_DCE_knie_grasp/'
end
P.file='fe_17102016_2102133_18_2_wip3ddcefemtrasenseV4.raw'
P.coil_survey='fe_17102016_2101366_1000_23_wipcoilsurveyscanV4.raw'
P.sense_ref='fe_17102016_2101584_1000_26_wipsenserefscanclearV4.raw' 

P.binparams.visualize =1;
% P.spokestoread=[0:250]';
P.reconslices=[10]

P.resultsfolder=[P.folder,'ResultsNew'];
P.filename='withprewh'
P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='sense' % sense2 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=2

P.enableTGV=1
P.GPU=0
P.prewhiten=1

P.saveMR=1
P.loadMR=0
P.clearcorr=1
[MR,P]=GoldenAngle(P)

