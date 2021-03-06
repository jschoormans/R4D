addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes'))
addpath(genpath('/home/jschoormans/toolbox/gpuNUFFT'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/imagine'))


clear all

P.folder='/home/jschoormans/lood_storage/divi/Projects/cosart/scans/FEM/20160803_CarotisDCE_FlipAngle15/'
P.file='20_03082016_1524321_5_2_wip3dradialdcesenseV4.raw'

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
size(MR.Data)

[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
w=abs(k); 

wGPU=col(w(:,:));
kGPU=zeros([2,numel(k(:,:))]);
kGPU(1,:)=real(col(k(:,:)));
kGPU(2,:)=imag(col(k(:,:)));
kGPU=single(kGPU);

sens=ones(224,224,8);

osf = 2; wg = 3; sw = 8;
NUFFTOP=gpuNUFFT(kGPU.',(wGPU),osf,wg,sw,[224 224],sens,true);


tic
for slice=1:60
    y=MR.Data(:,:,slice,:);
    y=reshape(y,[],8);
    y=bsxfun(@times,y,sqrt(w(:))); 
    R(:,:,slice)=(NUFFTOP'*y); %first guess
end
disp('time taken for 2d GPU:'),toc

sl=30
figure(1); 
imshow(abs(R(:,:,sl,1)),[])
title('2D on GPU')

%%

disp('Single-channel 3D GPU - no sens');

kdata=fft(MR.Data,[],3);         %eventually: remove slice oversampling
size(kdata);

[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
w=abs(k);

wGPU=col(w(:,:));
kGPU=zeros([2,numel(k(:,:))]);
kGPU(1,:)=real(col(k(:,:)));
kGPU(2,:)=imag(col(k(:,:)));
kGPU(3,:)=0; 
kGPU=single(kGPU);

k_all=repmat(kGPU,[1 1 60]);
k_all=reshape(k_all,3,[]);

k_all_z=[-30:29]/60;
k_all_z=repmat(k_all_z,[186368 1]);
k_all_z=k_all_z(:); 
k_all(3,:)=k_all_z;

w_all=repmat(wGPU,[1 1 60]);
w_all=w_all(:); 

osf = 1; wg = 3; sw = 8;
NUFFTOP=gpuNUFFT(k_all,w_all,osf,wg,sw,[112 112 50],[],true);

y=kdata(:,:,:,1);
y=reshape(y,[],1);
y=bsxfun(@times,y,sqrt(w_all(:))); 
R2=(NUFFTOP'*y); %first guess


sl=16
figure(2); 
imshow(abs(R2(:,:,sl,1)),[])
disp('Done')

figure(3); 
imshow(squeeze(abs(R2(:,112,:,1))),[])
disp('Done')

%%
disp('multi-channel 3D GPU - no sense maps');

kdata=fft(MR.Data,[],3);         %eventually: remove slice oversampling
size(kdata);

[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
w=abs(k);

wGPU=col(w(:,:));
kGPU=zeros([2,numel(k(:,:))]);
kGPU(1,:)=real(col(k(:,:)));
kGPU(2,:)=imag(col(k(:,:)));
kGPU(3,:)=0; 
kGPU=single(kGPU);

k_all=repmat(kGPU,[1 1 60]);
k_all=reshape(k_all,3,[]);

k_all_z=[-30:29]/60;
k_all_z=repmat(k_all_z,[186368 1]);
k_all_z=k_all_z(:); 
k_all(3,:)=k_all_z;

w_all=repmat(wGPU,[1 1 60]);
w_all=w_all(:); 

sens=ones(112,112,50,2);

osf = 1; wg = 3; sw = 8;
NUFFTOP=gpuNUFFT(k_all,w_all,osf,wg,sw,[112 112 50],[],true);

y=kdata(:,:,:,1:2);
y=reshape(y,[],2);
y=bsxfun(@times,y,sqrt(w_all(:))); 
R2=(NUFFTOP'*y); %first guess


sl=16
figure(4); 
imshow(abs(R2(:,:,sl,1)),[])
figure(5); 
imshow(abs(R2(:,:,sl,2)),[])
disp('Done')

% Note: can this be used for temporal frames (instead of loop?) 
% --> not when using sense maps 

%%

disp('multi-channel 3D GPU - with sense maps');

kdata=fft(MR.Data,[],3);         %eventually: remove slice oversampling
size(kdata);

[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
w=abs(k);

wGPU=col(w(:,:));
kGPU=zeros([2,numel(k(:,:))]);
kGPU(1,:)=real(col(k(:,:)));
kGPU(2,:)=imag(col(k(:,:)));
kGPU(3,:)=0; 
kGPU=single(kGPU);

k_all=repmat(kGPU,[1 1 60]);
k_all=reshape(k_all,3,[]);

k_all_z=[-30:29]/60;
k_all_z=repmat(k_all_z,[186368 1]);
k_all_z=k_all_z(:); 
k_all(3,:)=k_all_z;

w_all=repmat(wGPU,[1 1 60]);
w_all=w_all(:); 

sens=ones(224,224,50,8);

osf = 1.2; wg = 3; sw = 8;
NUFFTOP=gpuNUFFT(k_all,w_all,osf,wg,sw,[224 224 50],sens,true);

y=kdata(:,:,:,:);
y=reshape(y,[],8);
y=bsxfun(@times,y,sqrt(w_all(:))); 

tic
R2=(NUFFTOP'*y); %first guess
disp('3D NUFFT TIME:'),toc

sl=1
figure(6); 
imshow(abs(R2(:,:,sl)),[])
title('3D with sense maps on GPU')
disp('Done')

% oversampling factor 2 werkt niet
% er zit nog een checkerboard correction in de z-richting. 
% 3D GPU versus 2D loop GPU is about 1.55 s (3D) veruses 2.4 sec (2D). 


%%
disp('multi-channel 3D GPU - with sense maps and timeframes');
disp('not possible in combination with a sense maps');

%% Test operator 

disp('multi-channel 3D GPU - with sense maps - OPERATOR');

kdata=fft(MR.Data,[],3);         %eventually: remove slice oversampling
size(kdata);

[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
w=abs(k);

% sort in timeframes...
nspokes=100
nt=4

clear kdata_sorted k_sorted w_sorted
for ii=1:nt
    spoke_coords=((ii-1)*nspokes+1):(ii)*nspokes;
    kdata_sorted(:,:,:,:,ii)= kdata(:,spoke_coords,:,:);
   k_sorted(:,:,ii)=k(:,spoke_coords);
   w_sorted(:,:,ii)=w(:,spoke_coords);
end



clear w_all_t k_all_t
for ii=1:nt

kGPU=zeros([2,numel(k_sorted(:,:,ii))]);
kGPU(1,:)=real(col(k_sorted(:,:,ii)));
kGPU(2,:)=imag(col(k_sorted(:,:,ii)));
kGPU(3,:)=0; 
kGPU=single(kGPU);

k_all=repmat(kGPU,[1 1 60]);
k_all=reshape(k_all,3,[]);

k_all_z=[-30:29]/60;
k_all_z=repmat(k_all_z,[numel(k_sorted(:,:,ii)) 1]);
k_all_z=k_all_z(:); 
k_all(3,:)=k_all_z;

k_all_t(:,:,ii)=k_all;

wGPU=col(w_sorted(:,:,ii));
w_all=repmat(wGPU,[1 1 60]);
w_all_t(:,ii)=w_all(:);
end

size(k_all_t)
size(w_all_t)



sens=ones(224,224,50,8);
NUFFTOP=GPUNUFFTT3D(k_all_t,sqrt(w_all_t),sens);

y=kdata_sorted;
y=reshape(y,[],8,nt);
size(y)

y=bsxfun(@times,y,sqrt(permute(w_all_t,[1 3 2]))); 


tic
R2=(NUFFTOP'*y); %first guess
disp('3D NUFFT TIME:'),toc

sl=40
figure(7)
subplot(2,2,1)
imshow(abs(R2(:,:,sl,1)),[])
title('3D with sense maps on GPU - OPERATOR')
subplot(2,2,2)
imshow(abs(R2(:,:,sl,2)),[])
title('3D with sense maps on GPU - OPERATOR')


disp('Done')

% NOTES
% AMAZING IT WORKS
% NOW TO BUILD IN THE RECON - CARE TO DO THE RESHAPING RIGHT IN THE
% OPERATOR...







