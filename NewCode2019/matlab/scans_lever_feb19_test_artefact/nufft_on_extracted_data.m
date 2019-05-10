%ksp=h5read('recon_FEM_20190325T092035_saveMRData.h5','/Data');

load('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/NewCode2019/matlab/temp/temp_50b6972a-01e3-4f44-9324-59dd772d53b4/temp_data_slice_20.mat')
%%
ksp1=Ksl(:,:,1,1,26);
ksp1=permute(ksp1,[3 1 2]); 
size(ksp1)

traj=bart('traj -r -G -x512 -y34');

bartnufft=bart('nufft -i -t',traj(:,:,1:2:end),ksp1(:,:,1:2:end));
figure(1); imshow(abs(squeeze(bartnufft)),[]);

nx=512
ntviews=34
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],111.246+180);
res=nx;
clear coords
coords(1,:,:,:)=real((k(:,:,:))).*res;
coords(2,:,:,:)=imag((k(:,:,:))).*res;
coords(3,:,:,:)=zeros(size(k(:,:,:)));
size(coords)

bartnufft=bart('nufft -i -t',coords,ksp1);
figure(2); imshow(abs(squeeze(bartnufft)),[]);
