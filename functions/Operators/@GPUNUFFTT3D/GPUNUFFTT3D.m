function res= GPUNUFFTT3D(k,w,b1)
% Multicoil -multiframe GPU NUFFT operator for stack-of-stars 3D
% k should be given as [3,N,ntimeframes]
assert(size(k,1)==3); 

osf = 1.8; wg = 3; sw = 8;
ImageDim=[size(b1,1),size(b1,2), size(b1,3)]; % or whatever
res.adjoint = 0;
res.imSize=ImageDim;
res.nt=size(k,3);
res.b1=b1;
res.w=w;
res.dataSize = size(k,2);
res.ncoils=size(b1,4); 

for tt=1:res.nt
    wGPU=single(col(w(:,tt)));
    kGPU=single(k(:,:,tt));
    res.gNUFFT{tt}=gpuNUFFT(kGPU,wGPU,osf,wg,sw,ImageDim,single(b1),true);
end

res=class(res,'GPUNUFFTT3D');
end