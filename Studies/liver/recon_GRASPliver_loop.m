
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


lambdafacs = [1e-1, 1e0, 1e1, 1e2, 1e3, 1e4, 1e5]
for lambdafactor = lambdafacs
    P=struct
    if ispc()
        %         P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAA_001\2018_10_29\Ar_482423\'
        % P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAB_002\2018_10_31\Va_484209\'
    else
        P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/DCErecon/DCErecon_016/2019_10_04/DC_164850/'
    end
    P.file='dc_04102019_0928210_9_2_dce_3mmV4.raw'
    P.sense_ref='dc_04102019_0913531_1000_16_senserefscanV4.raw'
    P.coil_survey='log_dc_04102019_0910137_1000_8_coilsurveyscanV4.raw'
    
    
    P.binparams.visualize =1;
    P.resultsfolder=[P.folder,'Results'];
    P.recontype='DCE-2D'
    P.DCEparams.nspokes=55
    P.DCEparams.display=1;
    P.sensitvitymapscalc='espirit' %
    P.channelcompression=false;
    P.cc_nrofchans=6;
    P.filename=['scan_9_55sp_lambdafac', num2str(lambdafactor)]
    
    P.DCEparams.Beta='FR'
    P.DCEparams.nite=8 % should be 8
    P.DCEparams.outeriter=3
    P.DCEparams.lambdafactor = lambdafactor
    
    P.clearcorr=1
    P.enableTGV=1
    
    [MR,P]=GoldenAngle(P)
    
end

