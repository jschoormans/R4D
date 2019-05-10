function ress = mtimes(a,bb)

 if a.adjoint
     % Multicoil non-Cartesian k-space to Cartesian image domain
     % nufft for each coil and time point
     for tt=1:size(bb,4)
         b = bb(:,:,:,tt);%.*sqrt(a.w(:,:,tt));
         b=reshape(b,[size(b,1)*size(b,2),size(b,3)]);
         ress(:,:,tt) = reshape((a.gNUFFT{tt}'*b)/sqrt(prod(a.imSize)),a.imSize(1),a.imSize(2));
     end
     
     
     % compensate for undersampling factor (done in w!)
     %res=res*size(a.b1,1)*pi/2/size(a.w,2);     
     % coil combination for each time point
%      
%      for tt=1:size(bb,4)
%          ress(:,:,tt)=(sum(res(:,:,:,tt).*(a.b1),3)./sum(abs((a.b1)).^2,3)); %#ok<AGROW>
%      end
%      
     
 else
     
     % Cartesian image to multicoil non-Cartesian k-space 
     for tt=1:size(bb,3)
        
        res=bb(:,:,tt);
        ress(:,:,:,tt) = reshape((a.gNUFFT{tt}*res)/sqrt(prod(a.imSize)),[a.dataSize(1),a.dataSize(2),a.ncoils]); %.*a.w(:,:,tt);

%       ress(:,:,ch,tt) = reshape(nufft(res,a.st{tt})/sqrt(prod(a.imSize)),a.dataSize(1),a.dataSize(2)).*a.w(:,:,tt);

     end
 end
       
 
 
