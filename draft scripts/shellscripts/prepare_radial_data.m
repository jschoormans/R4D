% RECONS OF FEM DCE SLICE 

addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/DCE_code/'))

%% test new code
% include corrections (BART), + prewhitening...

%% CHECK RECONS WITH/WITHOUT TGV AND WITH DIFFERENT BETAS (PREVIOUS RECON IS RUNNNING_ CANT CHANGE THE CODE TO CHANGE LAMBDA NOW!

% Betavector={'FR','PR','PR_restart','LS','LS_restart','MLS','HHS','HZ'}

com_counter=1
Betavector={'LS_restart'}

P=struct
P.folder=['/home/jschoormans/lood_storage/divi/Projects/femoral/FEM/FEM001_01/']
cd(P.folder)
P.file=findDCEfile(P.folder)

P.resultsfolder=['/home/jschoormans/lood_storage/divi/Projects/femoral/matlab/perform_recons/temp'];
P.filename=['recon_FEM_',datestr(now,30)]
P.recontype='DCE'
P.DCEparams.nspokes=34
P.DCEparams.display=1;
P.sensitvitymapscalc='espirit'
P.channelcompression=true;
P.cc_nrofchans=6;
P.reconslices=[20];

P.DCEparams.Beta=Betavector{1}
P.enableTGV=1

[MR,P]=GoldenAngle(P)


%% TO DO: RUN LOOP FOR DIFFERENT LAMBDA