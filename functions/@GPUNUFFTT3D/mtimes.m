function ress = mtimes(a,bb)

 if a.adjoint
     % Multicoil non-Cartesian k-space to Cartesian image domain
     % nufft for each coil and time point
     for tt=1:size(bb,4)
         b = bb(:,:,:,:,tt);
         b=reshape(b,[size(b,1)*size(b,2)*size(b,3),size(b,4)]);
         ress(:,:,:,tt) = reshape((a.gNUFFT{tt}'*b),a.imSize(1),a.imSize(2),a.imSize(3));         
     end
     
     
else
     
     % Cartesian image to multicoil non-Cartesian k-space 
     for tt=1:size(bb,3)
        res=bb(:,:,:,tt);
        ress(:,:,:,tt) = reshape((a.gNUFFT{tt}*res(:)),[a.dataSize(1),a.dataSize(2),a.dataSize(3),a.ncoils]);
     end
 end
       
 
 
