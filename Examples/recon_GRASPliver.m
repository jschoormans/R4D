
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
dbstop if error

P=struct
if ispc()
%         P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAA_001\2018_10_29\Ar_482423\'
% P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAB_002\2018_10_31\Va_484209\'
P.folder='L:\basic\divi\Projects\dcerecon\MRI\labraw\Substudy V\AAC_003\2018_11_02\Tr_487629\'
else
end
% P.file='ar_29102018_0755273_4_2_dce_liver_sos_contrV4.raw'
% P.file='va_31102018_1005436_9_2_dce_liver_sos_contrV4.raw'
P.file='tr_02112018_0855057_7_2_dce_liver_sos_fovV4.raw'
P.sense_ref='ar_29102018_0752270_1000_5_senserefscanV4.raw'
P.coil_survey='ar_29102018_0749017_1000_2_coilsurveyscanV4.raw'


P.binparams.visualize =1;
% P.spokestoread=[0:300]';
P.reconslices=[15]

P.resultsfolder=[P.folder,'Results'];
P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='espirit' % 
P.channelcompression=true;
P.cc_nrofchans=6;
P.filename='scan6_sense'

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5

P.enableTGV=1
P.GPU=0

[MR,P]=GoldenAngle(P)

