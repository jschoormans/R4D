
%FLUX
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
setenv('TOOLBOX_PATH','/opt/amc/bart-0.4.01/bin/')

addpath(genpath('/home/jschoormans/toolbox'))

%%
clear all; close all; clc;

%femoral
P.folder='/home/jschoormans/lood_storage/divi/Projects/femoral/FEM/FEM10_01/'
P.file='fe_17102016_2102133_18_2_wip3ddcefemtrasenseV4.raw'
P.coil_survey='fe_17102016_2101366_1000_23_wipcoilsurveyscanV4.raw'
P.sense_ref='fe_17102016_2101584_1000_26_wipsenserefscanclearV4.raw' 


P.binparams.visualize =1;

P.resultsfolder=['/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp'];
P.filename=['target_GPU_results']


P.binparams.visualize =1;
P.spokestoread=[0:250]';
P.reconslices=[10]

P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='ones' % sense2 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=2

P.enableTGV=1
P.GPU=0
P.prewhiten=1

P.saveMR=0
P.loadMR=0
P.clearcorr=1
[MR,P]=GoldenAngle(P)
