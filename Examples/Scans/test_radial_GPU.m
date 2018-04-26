clear
load radial_testdata
%% make one frame 
k=[]; w=[];data=[];
for i=1:52
    k=cat(2,k,ku(:,:,i));
    w=cat(2,w,wu(:,:,i));
    data=cat(2,data,tempy(:,:,:,i));
end;
%% CPU Recon (5x slower than GPU... not amazing) 
NUFFTCPU=MCNUFFT(k,sqrt(w),sensmap);
tic
for i=1:10
rCPU=(NUFFTCPU'*data); %first guess
end
tCPU=toc; 

disp('Generate NUFFT Operator without coil sensitivities');
osf = 2; % oversampling: 1.5 1.25
wg = 3; % kernel width: 5 7
sw = 12; % parallel sectors' width: 12 16
imwidth = 320;

NUFFTGPU = gpuNUFFT([real(col(k)), imag(col(k))]',col(w),osf,wg,sw,[imwidth,imwidth],conj(sensmap),true);

tic 
for i=1:10
rGPU=NUFFTGPU'*reshape(data,[520*260,24]);
end
tGPU=toc


figure(1)

subplot(211)
imshow(abs(rCPU),[])
title(['CPU, t=',num2str(tCPU)])
subplot(212)
imshow(abs(rGPU),[])
title(['GPU, t=',num2str(tGPU)])
