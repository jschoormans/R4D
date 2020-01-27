
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

for iters=[2]

    P=struct
    
    if iters==1
        %target01
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2017_10_31_TARGET-01/TA_154472/'
        P.file='ta_31102017_1859312_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_08012018_1824030_1000_2_coilsurveyscanV4.raw'
        P.sense_ref='ta_08012018_1833035_1000_10_senserefscanV4.raw'
        
    elseif iters==2
        %target02
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_01_08_TARGET-02/2018_01_08/TA_238210/' %TARGET 002
        P.file='ta_08012018_1859329_8_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_08012018_1824030_1000_2_coilsurveyscanV4.raw'
        P.sense_ref='ta_08012018_1833035_1000_10_senserefscanV4.raw'
    elseif iters==3
        
        %target03
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_01_25_TARGET-03/2018_01_25/TA_257015/'
        P.file='ta_25012018_1813174_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_25012018_1740084_1000_2_coilsurveyscanV4.raw'
        P.sense_ref='ta_25012018_1748409_1000_10_senserefscanV4.raw'
    elseif iters==4
        
        %target04
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_02_20_TARGET-04/2018_02_20/TA_279655/'
        P.file='ta_20022018_1901267_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_20022018_1836485_1000_2_coilsurveyscanV4.raw'
        P.sense_ref='ta_20022018_1843225_1000_10_senserefscanV4.raw'
    elseif iters==5
        
        %target05
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_02_20_TARGET-05/2018_02_20/TA_279721/'
        P.file='ta_20022018_2003217_8_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_20022018_1933567_1000_10_coilsurveyscanV4.raw'
        P.sense_ref='ta_20022018_1937323_1000_16_senserefscanV4.raw'
    elseif iters==6
        
        %target06
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_02_26_TARGET-06/2018_02_26/TA_284518/'
        P.file='ta_26022018_1826401_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_26022018_1759405_1000_2_coilsurveyscanV4.raw'
        P.sense_ref='ta_26022018_1806553_1000_10_senserefscanV4.raw'
    elseif iters==7
        
        %target07
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_04_04_TARGET-07/2018_04_04/TA_314172/'
        P.file='ta_04042018_1643552_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_04042018_1616154_1000_10_coilsurveyscanV4.raw'
        P.sense_ref='ta_04042018_1619550_1000_16_senserefscanV4.raw'
    elseif iters==8
        
        %target08
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_04_09_TARGET-08/2018_04_09/TA_319519/'
        P.file='ta_09042018_1856540_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_09042018_1824171_1000_8_coilsurveyscanV4.raw'
        P.sense_ref='ta_09042018_1829201_1000_16_senserefscanV4.raw'
    elseif iters==9
        
        %target09
        P.folder='/home/jschoormans/lood_storage/divi/Projects/target/mri/recon/2018_06_12_TARGET-09/2018_06_12/TA_367462/'
        P.file='ta_12062018_1827390_7_2_wip_3d_dce_tra_1-2mmV4.raw'
        P.coil_survey='ta_12062018_1801228_1000_2_coilsurveyscanV4.raw'
        P.sense_ref='ta_12062018_1809378_1000_10_senserefscanV4.raw'
    end


P.binparams.visualize =1;
% P.spokestoread=[0:500]';%
% P.reconslices=[10:20]%

P.resultsfolder=[P.folder,'ResultsNew'];
P.filename=['tagret2_openadapt_34sp_500_CPU']
P.recontype='DCE-CPU'
P.DCEparams.nspokes=34; %34 %(2,3,5,8,13,21,34,...)
P.DCEparams.display=1;
P.sensitvitymapscalc='sense2' % sense2 
P.channelcompression=true;
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
end
