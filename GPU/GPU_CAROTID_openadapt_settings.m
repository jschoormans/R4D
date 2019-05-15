% GPU RECON CAROTID
% because the GoldenAngle has gotten too big/complicated, I only copy/paste
% the relevant code here
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/imagine'))

%%
% 15 mei 2018
% temporary draft script. 


clear all
P=struct()
P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160803_CarotisDCE_FlipAngle15/'
P.file='20_03082016_1524321_5_2_wip3dradialdcesenseV4.raw'

%P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160705_CarotidDCE/'
%P.file='20_06072016_1302465_6_2_wip3d07mmradialtestsenseV4.raw'

%P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160615_Carotid/'
%P.file='20_15062016_1913278_8_2_wip3dimsdegoldenanglesenseV4.raw'

% P.spokestoread=[0:300]';
%P.reconslices=[10:12]

P.recontype='DCE'
P.DCEparams.nspokes=37
P.DCEparams.display=1;
P.sensitvitymapscalc='openadapt' % 
P.channelcompression=false;
P.cc_nrofchans=6;

P.DCEparams.Beta='FR'
P.DCEparams.nite=8 % should be 8
P.DCEparams.outeriter=5
P.DCEparams.display=0

P.enableTGV=1
P.GPU=1
P.prewhiten=0


%%
tic 
fprintf('\nCarotid DCE Reconstruction...\n\n')
P=checkGAParams(P);

MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);  %update read paramters based on MR object params

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
    fprintf('Prewhitening...')
    
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
    L = chol(psi,'lower');
    L_inv = inv(L);
    data_corr = conj(L_inv) * data;
    data_corr=data_corr.';
    
if P.prewhiten

    MR.Data=reshape(data_corr,sizeMRDATA);
    fprintf('Finished\n')
end
fprintf('\nprewhiten...');toc
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


%% run different combinations


ctr=1

norm=[true,false]
zerofillp=permute(zerofill,[4 1 2 3]);

figure(1); clf;
fprintf('Running different combinations...')
for ii=1:2
    for jj=1:2
        
        if jj==1 % no whiten in sens
            [~, ~, sens] = openadapt(zerofillp,norm(ii));
            
            %            sens=bsxfun(@rdivide,sens, sqrt(sum((sens.^2),4)));
        else    % whiten in sens 
            disp('whiten in sens')
            [~, ~, sens] = openadapt(zerofillp,norm(ii),psi);
            
            %           sens=bsxfun(@rdivide,sens, sqrt(sum((sens.^2),4)));
        end
        
        sens=permute(sens,[2 3 4 1]); 
        for selectslice=20       % sort the data into a time-series
            tempy=squeeze(double(kdatau(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
            NUFFTOP=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
            image{ii,jj}=(NUFFTOP'*tempy); %first guess
        end
        
        
        subplot(2,2,ctr)
        imshow(abs(image{ii,jj}(:,:,3)),[])
        title(['ii=',num2str(ii),' | jj=',num2str(jj)])
        ctr=ctr+1;
    end
end







