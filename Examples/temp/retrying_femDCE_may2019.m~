% RECONS OF FEM DCE SLICE 
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))


cd('/home/jschoormans/lood_storage/divi/Projects/cosart/ISMRM17')

resultsfolder='/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp'

%% CHECK RECONS WITH/WITHOUT TGV AND WITH DIFFERENT BETAS (PREVIOUS RECON IS RUNNNING_ CANT CHANGE THE CODE TO CHANGE LAMBDA NOW!
    

femfile='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160803_CarotisDCE_FlipAngle15/20_03082016_1524321_5_2_wip3dradialdcesenseV4.raw'

MR=GoldenAngle_Recon(femfile); %initialize MR object

%%

P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160803_CarotisDCE_FlipAngle15/'
P.file='20_03082016_1524321_5_2_wip3dradialdcesenseV4.raw'
P.resultsfolder='/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp'

P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/jschoormans/carotid_DCE/2019_05_10/'
P.file='ca_10052019_1042568_6_2_carotid_dce_shortV4.raw'
P.resultsfolder='/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp'


P.binparams.visualize =1;
% P.spokestoread=[0:300]';
P.reconslices=[9:20]

P.resultsfolder=[P.folder,'Results'];
P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='openadapt' % 
P.channelcompression=false;
P.cc_nrofchans=6;
P.filename='scan6_sense'

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5

P.enableTGV=1
P.GPU=0

[MR,P]=GoldenAngle(P)