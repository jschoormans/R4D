function res= GPUNUFFTT(k,w,b1)
% Multicoil -multiframe GPU NUFFT operator 


%temp
w=sqrt(abs(k));

osf = 2; wg = 3; sw = 8;
ImageDim=[size(b1,1),size(b1,2)]; % or whatever
res.adjoint = 0;
res.imSize=ImageDim;
res.nt=size(k,3);
res.b1=b1;
res.w=w;
res.dataSize = size(k);
res.ncoils=size(b1,3); 

for tt=1:res.nt


    wGPU=col(w(:,:,tt));
    kGPU=zeros([2,numel(k(:,:,tt))]);
    kGPU(1,:)=real(col(k(:,:,tt)));
    kGPU(2,:)=imag(col(k(:,:,tt)));
    kGPU=single(kGPU);
    res.gNUFFT{tt}=gpuNUFFT(kGPU,wGPU,osf,wg,sw,ImageDim,squeeze(b1),true);
end



res=class(res,'GPUNUFFTT');
end