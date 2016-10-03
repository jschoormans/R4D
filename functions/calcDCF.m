function DCF=calcDCF(ku,effMtx)
%converts stacks-of-stars radial trajectory and puts it in iterative DCF
%function calculations!!!!



for frame=1:size(ku,3)
coords(1,:,:)=real((ku(:,:,frame)));
coords(2,:,:)=imag((ku(:,:,frame)));
coords(3,:,:)=zeros(size(ku(:,:,frame)));
verbose = 1
osf = 1.5
numIter = 10
pre = sdc3_MAT(coords,numIter,effMtx,verbose,osf);
osf = 2.1
numIter = 30
DCF(:,:,frame) = sdc3_MAT(coords,numIter,effMtx,verbose,osf,pre);
end