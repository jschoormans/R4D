% GPU RECON CAROTID
% because the GoldenAngle has gotten too big/complicated, I only copy/paste
% the relevant code here
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))

clear all

P=struct()
P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160803_CarotisDCE_FlipAngle15/'
P.file='20_03082016_1524321_5_2_wip3dradialdcesenseV4.raw'
P.resultsfolder='/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp'
% 
% P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160705_CarotidDCE/'
% P.file='20_06072016_1302465_6_2_wip3d07mmradialtestsenseV4.raw'


%P.spokestoread=[0:300]';
P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='openadapt' % 
P.channelcompression=false;
P.cc_nrofchans=3;
P.filename='recon_GPU_dev'

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5
P.DCEparams.display=0

P.enableTGV=1
P.GPU=1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create temp folder
P.reconID=[char(java.util.UUID.randomUUID)];
% create temp folder to save data 
P.foldertemp=[P.resultsfolder,filesep,'temp_',P.reconID];
mkdir(P.foldertemp); 

%%
tic 
fprintf('\nCarotid DCE Reconstruction...\n\n')

P=checkGAParams(P);

MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);  %update read paramters based on MR object params

MR.Perform1;                        %reading and sorting data
MR.CalculateAngles;
MR.PhaseShift;
%MR.Data=ifft(MR.Data,[],3);         %eventually: remove slice oversampling
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

kdata=squeeze(ifft(MR.Data,[],3)); %select kdata for slice
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
img_sens_sos = sqrt(sum(abs(sens).^2,4));
sens = sens./repmat(img_sens_sos,[1,1,1,8]);


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

% zres=max(unique(MR.Parameter.Encoding.ZRes));    % 2017-01-23 pdh added
% slices_to_keep=[1+((ny-zres)/2):zres+((ny-zres)/2)];
% slices_to_keep=floor(slices_to_keep);
% kdatau=kdatau(:,:,slices_to_keep,:,:);

fprintf('\nsorting into timeframes...');toc
%% get first guess


kdatau2d=ifft(kdatau,[],3); 
tic
disp('First guess')
for selectslice=P.reconslices       % sort the data into a time-series
    fprintf('%d - ',selectslice)
    tempy=squeeze(double(kdatau(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
    
    NUFFTOP=GPUNUFFTT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
    R(:,:,selectslice,:)=(NUFFTOP'*tempy); %first guess
end
R(isnan(R))=0;
fprintf('\nFirst Guess...');toc

%% FIrst Guess - 3D operator case



clear w_all_t k_all_t


% THIS PART IS MAKING THE 3D stack-of-stars should be put somewhere else...
for ii=1:nt

kGPU=zeros([2,numel(ku(:,:,ii))]);
kGPU(1,:)=real(col(ku(:,:,ii)));
kGPU(2,:)=imag(col(ku(:,:,ii)));
kGPU(3,:)=0; 
kGPU=single(kGPU);

k_all=repmat(kGPU,[1 1 60]);
k_all=reshape(k_all,3,[]);

k_all_z=[-30:29]/60;
k_all_z=repmat(k_all_z,[numel(ku(:,:,ii)) 1]);
k_all_z=k_all_z(:); 
k_all(3,:)=k_all_z;

k_all_t(:,:,ii)=k_all;

wGPU=col(wu(:,:,ii));
w_all=repmat(wGPU,[1 1 60]);
w_all_t(:,ii)=w_all(:);
end

size(k_all_t)
size(w_all_t)


NUFFTOP=GPUNUFFTT3D(k_all_t,sqrt(w_all_t),sens);

y=kdatau;
cc=create_checkerboard(size(kdatau,3));
y=bsxfun(@times,y,permute(cc,[1 3 2])); 

y=reshape(y,[],nc,nt);  % THIS SHOULD BE MOVED TO THE OPERATOR
size(y)

y=bsxfun(@times,y,sqrt(permute(w_all_t,[1 3 2]))); 


tic
R2=(NUFFTOP'*y); %first guess
disp('3D NUFFT TIME:'),toc

imagine(R,'Name','2d',R2,'Name','3D')


%%



%% some parameters that are needed during recon/saving

P.DCEparams.lambda = double(P.DCEparams.lambdafactor*max(abs(R2(:))));  %regularization
P.voxelsize=MR.Parameter.Scan.AcqVoxelSize;

%% write big files to temporary folder
%{
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
%}
%%  L1 minimization algorithm (NLCG)

fprintf('\n GRASP reconstruction (3D on GPU) \n')
% 
%     % load relevant data
%     cd(P.foldertemp)
%     name=['temp_data_slice_',num2str(selectslice),'.mat'];
%     vars=load(name);
    
    
%     NufftOP=GPUNUFFTT(P.ku,sqrt(P.wu),double(squeeze(vars.senssl)));
    


%     k_weighted=squeeze(double(vars.Ksl)).*permute(repmat(sqrt(P.wu),[1 1 1 nc]),[1 2 4 3]);

%     res=(single(squeeze(vars.Rsl)));


% to do: 
% fix l1-norm (TV temp operator in 3D)
P.DCEparams.lambda=10000;
P.DCEparams.display=1;
P.DCEparams.W=TV_Temp_3D();

res=R2; %first-guess 

y=kdatau;
cc=create_checkerboard(size(kdatau,3));
y=bsxfun(@times,y,permute(cc,[1 3 2])); 

y=reshape(y,[],nc,nt);  % THIS SHOULD BE MOVED TO THE OPERATOR
size(y)


for outeriter=1:P.DCEparams.outeriter
    res=CSL1NlCg_GPU(res,P.DCEparams,y,NUFFTOP);
end

recon_cs = gather(res);

imagine(recon_cs)

%{
%% CLEAR CORR
if P.clearcorr
temp=1
clearmap=sum(abs(senssl),4).^1;
reconCLEAR1=bsxfun(@times,recon_cs(:,:,10,:),clearmap);
size(reconCLEAR1)
imshow(abs(reconCLEAR1(:,:,1,1)),[])
end
%% save as nifiti...

description='description'
cd(P.resultsfolder)
nii=make_nii(squeeze(abs(flip((permute(recon_cs(:,:,:,:),[2 1 3 4]))))),P.voxelsize,[],[],description);
save_nii(nii,strcat(P.filename,'CS_N_FR','.nii'))

[MR,P] = SaveReconResults(MR,P); % SAVES THE TEXT FILE WITH PARAMETERS

%% remove temp folder
%rmdir(P.foldertemp,'s');









%}





