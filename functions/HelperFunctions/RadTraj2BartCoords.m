function coords=RadTraj2BartCoords(k,res) %2D

coords(1,:,:,:)=real((k(:,:,:))).*res;
coords(2,:,:,:)=imag((k(:,:,:))).*res;
coords(3,:,:,:)=zeros(size(k(:,:,:)));
coords=permute(coords,[1 2 3 5 6 7 8 9 10 11 4]);


end  