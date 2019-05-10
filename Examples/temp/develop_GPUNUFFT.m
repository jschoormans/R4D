cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp')

addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes/'))
addpath(genpath('/home/jschoormans/toolbox/'))

load('carotiddata.mat')

% remove temporal domain for this test
ku=ku(:,:,1);
wu=wu(:,:,1);
tempy=tempy(:,:,8);
%%
tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,8,:)));
temprecon=(tempE'*tempy); %first guess

figure(2)
imshow(abs(temprecon(:,:,1)),[0 1000])

%%
%k should be Nx3 size
imageDim=[224,224,1]


% DOES NOT WORK YET... 
% MATLAB GIVES FAULTS --> NOT IN DEMO. FIND OUT WHY. 

k2=zeros([2,numel(ku)]);
k2(1,:)=real(ku(:));
k2(2,:)=imag(ku(:));
k2=single(k2);
k2=k2.'

sens2=single((sens(:,:,10,:)));

w2=single(col(wu));

size(k2)
size(w2)
size(sens2)


%%
osf = 2; wg = 3; sw = 8;

NUFFTOPGPU=gpuNUFFT(k2.',w2,osf,wg,sw,[224 224],[],true)
%NUFFTOPGPU=gpuNUFFT(k',col(w(:,:,1)),osf,wg,sw,imageDim,[],true)
%NUFFTOPGPU=gpuNUFFT(k',col(w(:,:,1)),osf,wg,sw,[1,224,1],[],true);
