function [MR,P]=FullRecon_SoS_DCE(P)

tic 
fprintf('\n DCE Reconstruction - 3D on GPU...\n\n')

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
sens = sens./repmat(img_sens_sos,[1,1,1,nc]);


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


%% FIrst Guess - 3D operator case



clear w_all_t k_all_t


% THIS PART IS MAKING THE 3D stack-of-stars should be put somewhere else...
for ii=1:nt

kGPU=zeros([2,numel(ku(:,:,ii))]);
kGPU(1,:)=real(col(ku(:,:,ii)));
kGPU(2,:)=imag(col(ku(:,:,ii)));
kGPU(3,:)=0; 
kGPU=single(kGPU);

k_all=repmat(kGPU,[1 1 ny]);
k_all=reshape(k_all,3,[]);

k_all_z=[-MR.Parameter.Labels.KzRange(2)-1:MR.Parameter.Labels.KzRange(2)]/ny;

if length([-MR.Parameter.Labels.KzRange(2)-1:MR.Parameter.Labels.KzRange(2)]) == ny+1
    k_all_z = k_all_z(2:end); 
    % sometimes the data has one fewer kpoint in z than expected
    % in that case remove the lowest kz 
end

k_all_z=repmat(k_all_z,[numel(ku(:,:,ii)) 1]);
k_all_z=k_all_z(:); 
k_all(3,:)=k_all_z;

k_all_t(:,:,ii)=k_all;

wGPU=col(wu(:,:,ii));
w_all=repmat(wGPU,[1 1 ny]);
w_all_t(:,ii)=w_all(:);
end


NUFFTOP=GPUNUFFTT3D(k_all_t,sqrt(w_all_t),sens);

y=kdatau;
cc=create_checkerboard(size(kdatau,3));
y=bsxfun(@times,y,permute(cc,[1 3 2])); 

y=reshape(y,[],nc,nt);  % THIS SHOULD BE MOVED TO THE OPERATOR
y=bsxfun(@times,y,sqrt(permute(w_all_t,[1 3 2]))); 


tic
R2=(NUFFTOP'*y); %first guess
disp('3D NUFFT TIME:'),toc

%% some parameters that are needed during recon/saving

P.DCEparams.lambda = double(P.DCEparams.lambdafactor*max(abs(R2(:))));  %regularization
P.voxelsize=MR.Parameter.Scan.AcqVoxelSize;


%%  L1 minimization algorithm (NLCG)

fprintf('\n GRASP reconstruction (3D on GPU) \n')

P.DCEparams.W=TV_Temp_3D();

res=R2; %first-guess 

y=kdatau;
cc=create_checkerboard(size(kdatau,3));
y=bsxfun(@times,y,permute(cc,[1 3 2])); 
y=reshape(y,[],nc,nt);  % THIS SHOULD BE MOVED TO THE OPERATOR

for outeriter=1:P.DCEparams.outeriter
    res=CSL1NlCg_GPU(res,P.DCEparams,y,NUFFTOP);
end

recon_cs = gather(res);


%% CLEAR CORR
if P.clearcorr
% TO DO... ? 
end
%% save as nifiti...

description='GRASP';
cd(P.resultsfolder)
nii=make_nii(squeeze(abs(flip((permute(recon_cs(:,:,:,:),[2 1 3 4]))))),P.voxelsize,[],[],description);
save_nii(nii,strcat(P.filename,'CS_N_FR','.nii'))

[MR,P] = SaveReconResults(MR,P); % SAVES THE TEXT FILE WITH PARAMETERS


end
