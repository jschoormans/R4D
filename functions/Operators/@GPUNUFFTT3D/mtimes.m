function ress = mtimes(a,bb)

 if a.adjoint
     % Multicoil non-Cartesian k-space to Cartesian image domain
     % nufft for each coil and time point
     
     ress=zeros(a.imSize(1),a.imSize(2),a.imSize(3),size(bb,3));
     for tt=1:size(bb,3)
         b = bb(:,:,tt);
%          b=reshape(b,[size(b,1)*size(b,2)*size(b,3),size(b,4)]);
         ress(:,:,:,tt) = reshape((a.gNUFFT{tt}'*b),a.imSize(1),a.imSize(2),a.imSize(3));         
     end
     
     
else
     
     % Cartesian image to multicoil non-Cartesian k-space 
     for tt=1:size(bb,4);
        res=bb(:,:,:,tt);
        ress(:,:,tt) = reshape((a.gNUFFT{tt}*res(:)),[a.dataSize,a.ncoils]);
     end
 end
       
 
 
