cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Examples/temp')

addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/OtherToolboxes/'))
addpath(genpath('/home/jschoormans/toolbox/'))

load('carotiddata.mat')

% remove temporal domain for this test
ku=ku(:,:,1);
wu=wu(:,:,1);
tempy=tempy(:,:,:,1);

%%

%Like it is in the code:


fprintf('\n\n\nTesting Adjoint Ops NUFFT/ GPUNUFFT \n')

tic
for i=1:10
    tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,8,:)));
    temprecon=(tempE'*tempy); %first guess
end

disp('CPU')
toc

figure(2)
imshow(abs(temprecon(:,:,1)),[0 1000])


% GPU NUFFT %%%%%%%%%%%%%%%%
osf = 2; wg = 3; sw = 8;
ImageDim=[224,224]; % or whatever
sensGPU=single((sens(:,:,8,:)));
wGPU=wu(:);
kGPU=zeros([2,numel(ku)]);
kGPU(1,:)=real(ku(:));
kGPU(2,:)=imag(ku(:));
kGPU=single(kGPU);


yGPU=tempy;
yGPU=reshape(yGPU,[size(yGPU,1)*size(yGPU,2),size(yGPU,3)]);

tic
for i=1:10
    NUFFTOPGPU=gpuNUFFT(kGPU,sqrt(wGPU),osf,wg,sw,ImageDim,squeeze(sensGPU),true);
    tempreconGPU=(NUFFTOPGPU'*yGPU); %first guess
end

disp('GPU')
toc

figure(3)
imshow(abs(tempreconGPU(:,:,1)),[])

%%%%%%%%%%%%%%%%%%%

disp('forward')
tic
for i=1:10
    kspCPU=tempE*temprecon;
end
disp('CPU')
toc

tic
for i=1:10
    kspGPU=NUFFTOPGPU*temprecon;
end
disp('GPU')
toc

%%     tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,8,:)));

% COMPARE MCNUFFT and GPUNUFFTT
disp('run...')

clear classes
load('carotiddata.mat')


%wu=wu./max(wu(:)); 
wu=sqrt(abs(ku));

sens=bsxfun(@rdivide,sens, sqrt(sum(abs(sens).^2,4)));
ncoils=1:8;
ntf=1;


tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,8,ncoils)));
reconCPU=(tempE'*tempy(:,:,ncoils,ntf));

tempE2=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,8,ncoils)));
%reconGPU=(tempE2'*(tempy(:,:,ncoils,ntf).*(sqrt(wu(:,:,ntf)))));
reconGPU=(tempE2'*(tempy(:,:,ncoils,ntf)));

figure(10)
imshow(abs(reconCPU(:,:,1)),[])
figure(11)
imshow(abs(reconGPU(:,:,1)),[])

kspCPU=(tempE*reconCPU);
kspGPU=(tempE2*reconGPU);

reconCPU2=(tempE'*kspCPU);
reconGPU2=(tempE2'*(kspGPU));

kspCPU2=(tempE*reconCPU2);
kspGPU2=(tempE2*reconGPU2);

reconCPU3=(tempE'*kspCPU2);
reconGPU3=(tempE2'*(kspGPU2));


figure(12)
imshow(abs(reconCPU2(:,:,1)),[])
figure(13)
imshow(abs(reconGPU2(:,:,1)),[])


% forward operator


figure(1); clf
hold on
%plot(abs(reconCPU(112,:,1)),'k');
plot(abs(reconGPU(112,:,1)),'r');
%plot(abs(reconCPU2(112,:,1)),'k--');
plot(abs(reconGPU2(112,:,1)),'r--');
%plot(abs(reconCPU3(112,:,1)),'k-.');
plot(abs(reconGPU3(112,:,1)),'r-.');



legend('CPU','GPU','CPU-2','GPU-2','CPU-3','GPU-3')
hold off


%%
figure(1); clf
hold on
%plot(abs(tempy(:,1,1,ntf)./sqrt(wu(:,1,ntf))),'k');
plot(abs(tempy(:,10,1,ntf)),'k');
plot(abs(kspCPU(:,10,1)),'r--');
plot(abs(kspCPU2(:,10,1)),'r-.');

legend('CPU','GPU','CPU-2','GPU-2','CPU-3','GPU-3')
hold off

figure(2); clf;
plot(abs(tempy(:,10,1,ntf))./abs(kspCPU2(:,10,1)),'k');




%%
% TIME 

%%

fprintf('\n\n\nBenchmarking...\n')
disp('run ten times in parallel')
tic
parfor ii=1:10
tempE2=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,8,ncoils)));
kspGPU=(tempE2*reconGPU);
reconGPU2=(tempE2'*(kspGPU));
kspGPU2=(tempE2*reconGPU2);
reconGPU3=(tempE2'*(kspGPU2));
end
toc 


disp('run ten times in serial')
tic
for ii=1:10
tempE2=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,8,ncoils)));
kspGPU=(tempE2*reconGPU);
reconGPU2=(tempE2'*(kspGPU));
kspGPU2=(tempE2*reconGPU2);
reconGPU3=(tempE2'*(kspGPU2));
end
toc 


disp('run ten times in parallel (CPU)')
tic
parfor ii=1:10
    tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,8,ncoils)));
kspCPU=(tempE*reconCPU);
reconCPU2=(tempE'*kspCPU);
kspCPU2=(tempE*reconCPU2);
reconCPU3=(tempE'*kspCPU2);
end
toc 

disp('run ten times in serial (CPU)')
tic
for ii=1:10
    tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,8,ncoils)));
kspCPU=(tempE*reconCPU);
reconCPU2=(tempE'*kspCPU);
kspCPU2=(tempE*reconCPU2);
reconCPU3=(tempE'*kspCPU2);
end
toc 








