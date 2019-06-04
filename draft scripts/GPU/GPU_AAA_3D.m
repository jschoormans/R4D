% GPU RECON CAROTID
% because the GoldenAngle has gotten too big/complicated, I only copy/paste
% the relevant code here
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))
addpath(genpath('/opt/amc/matlab/toolbox/MRecon/'))


clear all
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Studies/AAA')
load('filelocations.mat')


study_nr=10
session_nr=1

P=struct();
P.folder=[F{study_nr,session_nr}.path,filesep];
P.file=F{study_nr,session_nr}.name;
P.resultsfolder='/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/DCE recons/';

P.recontype='DCE-2D';
P.DCEparams.nspokes=11;
P.DCEparams.display=1;
P.sensitvitymapscalc='openadapt' % 
P.channelcompression=true;
P.cc_nrofchans=3;
P.reconslices=[20].';

P.DCEparams.Beta='FR';
P.DCEparams.nite=2; % should be 8
P.DCEparams.outeriter=2;
P.DCEparams.display=0;

P.enableTGV=1;
P.GPU=1;

P.DCEparams.lambdafactor=0.25;
P.DCEparams.display=1;

MR=GoldenAngle(P);


