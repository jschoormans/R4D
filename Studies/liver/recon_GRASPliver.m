
if ispc()
    addpath(genpath('L:\basic\divi\Projects\cosart\Matlab\R4D\General_Code'))
    addpath(genpath('L:\basic\divi\Projects\cosart\Matlab\R4D\OtherToolboxes'))
else %linux
    addpath(genpath('/scratch/jschoormans/R4D'))
    addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))
end

%% MRECON VERSION
addpath(genpath('/opt/amc/matlab/toolbox/MRecon-3.0.556/'))

%%
clear all; close all; clc;
dbstop if error

P=struct
if ispc()
%         P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAA_001\2018_10_29\Ar_482423\'
% P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAB_002\2018_10_31\Va_484209\'
else
    P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/DCErecon/dcerecon_018/2019_11_22/DC_189965/'
end
P.file='dc_22112019_1458572_8_2_dce_2.5mm_fa22V4.raw'
P.sense_ref='dc_22112019_1444581_1000_10_senserefscanV4.raw'
P.coil_survey='dc_22112019_1438030_1000_2_coilsurveyscanV4.raw'


P.binparams.visualize =1;
% P.reconslices=[15]

P.resultsfolder=[P.folder,'Results'];
P.recontype='DCE-2D'
P.DCEparams.nspokes=55
P.DCEparams.display=1;
P.sensitvitymapscalc='espirit' % 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.lambdafactor = 1e1
P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=3
P.clearcorr=1;
P.enableTGV=1;

P.HammingFilterZeroFill = 1; 
% P.reconslices = 20; 
P.filename='test_17_normalize_sensmaps_Hamming_in_z'
[MR,P]=GoldenAngle(P)

