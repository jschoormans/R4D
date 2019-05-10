% test feb12 scan van Jurgen --> artefact.
% load data, save as cfl/ hd5


addpath(genpath('/opt/amc/matlab/toolbox/MRecon/'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/DCE_code/'))


%% CHECK RECONS WITH/WITHOUT TGV AND WITH DIFFERENT BETAS (PREVIOUS RECON IS RUNNNING_ CANT CHANGE THE CODE TO CHANGE LAMBDA NOW!

P=struct
P.folder=['/home/jschoormans/lood_storage/divi/Ima/parrec/jhrunge/Studies/DCErecon/Test_12FEB2019/2019_02_12/dc_35509/']
cd(P.folder)
P.file='dc_12022019_1854289_3_2_dce_liver_sos_3.5mmV4.raw'

P.resultsfolder=['/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/NewCode2019/matlab/temp'];
P.filename='recon_FEM_20190325T112736'
P.recontype='DCE'
P.DCEparams.nspokes=34
P.DCEparams.display=1;
P.sensitvitymapscalc='espirit'
P.channelcompression=false;
P.cc_nrofchans=6;
P.reconslices=[20];
P.prewhiten=1;
P.enableTGV=1
P.saveMR=1
P.reloadMR=1
[MR,P]=GoldenAngle(P)
