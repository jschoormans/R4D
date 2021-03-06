% GPU RECON CAROTID
% because the GoldenAngle has gotten too big/complicated, I only copy/paste
% the relevant code here
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/imagine'))
addpath(genpath('/opt/amc/matlab/toolbox/MRecon'))
%%

clear all
P=struct()
P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160803_CarotisDCE_FlipAngle15/'
P.file='20_03082016_1524321_5_2_wip3dradialdcesenseV4.raw'

%P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160705_CarotidDCE/'
%P.file='20_06072016_1302465_6_2_wip3d07mmradialtestsenseV4.raw'

%P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160615_Carotid/';
% %P.file='20_15062016_1913278_8_2_wip3dimsdegoldenanglesenseV4.raw';
% P.folder='/home/jschoormans/lood_storage/divi/Ima/parrec/jschoormans/carotid_DCE/2019_05_15/'
% P.file='ca_15052019_1527087_4_2_carotid_dce_shortV4.raw'
% P.file='ca_15052019_1535002_6_2_cdce-transvV4.raw'

% P.spokestoread=[0:300]';
% P.reconslices=[10];

P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='openadapt' % 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.Beta='FR';
P.DCEparams.nite=8; % should be 8
P.DCEparams.outeriter=10;
P.DCEparams.display=0;

P.enableTGV=1;
P.GPU=1;
P.clearcorr=1;
P.DCEparams.lambdafactor=0.5;
P.zerofill=1;

%%
tic 
fprintf('\nCarotid DCE Reconstruction...\n\n')
P=checkGAParams(P);

MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);  %update read paramters based on MR object params

%create temp folder
P.reconID=[char(java.util.UUID.randomUUID)];
% create temp folder to save data 
P.foldertemp=[P.resultsfolder,filesep,'temp_',P.reconID];
mkdir(P.foldertemp); 

MR.Perform1;                        %reading and sorting data
MR.CalculateAngles;
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3);         %eventually: remove slice oversampling
fprintf('\nloading data...');toc
%%
tic 
[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
fprintf('building trajectory...');toc

%%
tic
MRn=MR.Copy; MRn.Parameter.Parameter2Read.typ=5;
MRn.Parameter.Parameter2Read.echo=0;
MRn.ReadData;
P.eta=MRn.Data;

sizeMRDATA=size(MR.Data);
Ncoils=size(MR.Data,4);
Nsamples=numel(MR.Data)/Ncoils;
data=reshape(MR.Data,[Nsamples,Ncoils]);
data=data.';

psi = (1/(Nsamples-1))*(P.eta' * P.eta);

fprintf('\ncalculate noise correlation matrix...');toc
%% openadapt sense maps 
tic
res=MR.Parameter.Encoding.XReconRes;

kdata=squeeze(MR.Data); %select kdata for slice
w=getRadWeightsGA(k);
weighted_data=bsxfun(@times,kdata,sqrt(w));
NUFFTOP=NUFFT(k,sqrt(w),1,0,[res res],2);

fprintf('calculating separate coil/slice images for openadapt...\n')
tic
for selectslice=P.reconslices       % sort the data into a time-series
    fprintf('%d - ',selectslice)
    for selectcoil=[1:size(kdata,4)]
        zerofill(:,:,selectslice,selectcoil)=NUFFTOP'*double(kdata(:,:,selectslice,selectcoil));
    end
end
toc

zerofill=permute(zerofill,[4 1 2 3]); 
[~, ~, sens] = openadapt(zerofill,1,psi); % not sure about psi though
sens=permute(sens,[2 3 4 1]);

fprintf('\nopenadapt sense maps...');toc
%% sorting into timeframes; Remove oversampling in z-direction
tic
%%%SORTING
kdata=squeeze(MR.Data(:,:,:,:,1)); %select kdata for slice
nt=floor(ntviews/P.DCEparams.nspokes);              % calculate (max) number of frames
kdatac=kdata(:,1:nt*P.DCEparams.nspokes,:,:);       % crop the data according to the number of spokes per frame

for ii=1:nt       % sort the data into a time-series
    kdatau(:,:,:,:,ii)=kdatac(:,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes,:,:); %kdatau now (nfe nspoke nslice nc nt)
    ku(:,:,ii)=double(k(:,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes));
end

wu=getRadWeightsGA(ku);
clear kdatac kdata %clear memory
toc

zres=max(unique(MR.Parameter.Encoding.ZRes));    % 2017-01-23 pdh added
slices_to_keep=[1+((ny-zres)/2):zres+((ny-zres)/2)];
slices_to_keep=floor(slices_to_keep);
kdatau=kdatau(:,:,slices_to_keep,:,:);

fprintf('\nsorting into timeframes...');toc
%% get first guess

tic
disp('First guess')
for selectslice=P.reconslices       % sort the data into a time-series
    fprintf('%d - ',selectslice)
    tempy=squeeze(double(kdatau(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
    
    NUFFTOP=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
    R(:,:,selectslice,:)=(NUFFTOP'*tempy); %first guess
end
R(isnan(R))=0;
fprintf('\nFirst Guess...');toc



%% some parameters that are needed during recon/saving


P.DCEparams.lambda = double(P.DCEparams.lambdafactor*max(abs(R(:))));  %regularization


P.voxelsize=MR.Parameter.Scan.AcqVoxelSize;
P.ku=ku;
P.wu=wu;

%% write big files to temporary folder
fprintf('\nWriting temporary files:')

cd(P.foldertemp)

for sl=P.reconslices
    fprintf('%i - ',sl)
    name=['temp_data_slice_',num2str(sl),'.mat'];
    Ksl=kdatau(:,:,sl,:,:);
    Rsl=R(:,:,sl,:);
    senssl=sens(:,:,sl,:);
    save(name,'Ksl','Rsl','senssl')
end
fprintf('\n Finished \n')


% save general options
cd(P.foldertemp)
nameP='temp_options_P.mat';
save(nameP,'P');

%clear kdatau R sens;

%%  L1 minimization algorithm (NLCG)

for selectslice=P.reconslices;
    fprintf('\n GRASP reconstruction slice: %i of %i \n',selectslice,P.reconslices(end))

    % load relevant data
    cd(P.foldertemp)
    name=['temp_data_slice_',num2str(selectslice),'.mat'];
    vars=load(name);
    
    
    NufftOP=GPUNUFFTT(P.ku,sqrt(P.wu),double(squeeze(vars.senssl)));
    
    k_weighted=squeeze(double(vars.Ksl)).*permute(repmat(sqrt(P.wu),[1 1 1 nc]),[1 2 4 3]);
    res=(single(squeeze(vars.Rsl)));
    for outeriter=1:P.DCEparams.outeriter
        res=CSL1NlCg_GPU(res,P.DCEparams,k_weighted,NufftOP);
    end
    recon_cs(:,:,selectslice,:) = gather(res); 
end

%% CLEAR CORR
if P.clearcorr
    fprintf('clear correction...\n')
    clearmap=sum(abs(sens),4).^1;
    recon_cs=bsxfun(@times,recon_cs,clearmap);
end

%% ZEROFILL 
if P.zerofill
    for tt=1:size(recon_cs,4)
        recon_cs_interp(:,:,:,tt) = imresize3(recon_cs(:,:,:,tt),2);
    end
    P.voxelsize=P.voxelsize/2;
    
    description='GRASP';
    cd(P.resultsfolder)
    nii=make_nii(squeeze(abs(flip((permute(recon_cs_interp(:,:,:,:),[2 1 3 4]))))),P.voxelsize,[],[],description);
    save_nii(nii,strcat(P.filename,'interp','.nii'))
    
end

%% save as nifiti...

description='GRASP';
cd(P.resultsfolder)
nii=make_nii(squeeze(abs(flip((permute(recon_cs(:,:,:,:),[2 1 3 4]))))),P.voxelsize,[],[],description);
save_nii(nii,strcat(P.filename,'CS','.nii'))

fprintf('Finished\n')


[MR,P] = SaveReconResults(MR,P); % SAVES THE TEXT FILE WITH PARAMETERS

%% remove temp folder
rmdir(P.foldertemp,'s');















