cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/NewCode2019/matlab/scans_lever_feb19_test_artefact')

% data pre-processed by me

Noise=h5read('noise_all_coils.h5','/Noise');
% DataReal=h5read('data_all_coils_r30.h5','/Data');
% DataIm=h5read('data_all_coils_im30.h5','/Data');
DataReal=h5read('data_all_coils_nocorr_r30.h5','/Data');
DataIm=h5read('data_all_coils_nocorr_im30.h5','/Data');


Data=DataReal+1i*DataIm;

traj=bart('traj -r -G -x512 -y1280');

ksp=Data(:,1:1280,1,:);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
bartnufft=bart('nufft -i -t',traj(:,:,1:1:1280),ksp);


ncoils=size(Data,4)
for c=1:ncoils    
    figure(1); imshow(abs(squeeze(bartnufft(:,:,:,c))),[]);
    pause(0.3)
end

%
reconfull=bart('rss 8',bartnufft); 
size(reconfull)

figure(1); imshow(abs(squeeze(reconfull(:,:,1))),[]);
title('RSS coil combination')

%%

figure(2)
montage(abs(bartnufft(:,:,:,17:26)),'DisplayRange',[0 2])

figure(3)
imshow(abs(squeeze(bartnufft(:,:,:,25))),[])

%%
% check k-space of coil image 25
figure(4)
imshow(abs(squeeze(ksp(:,:,:,25))),[])

griddedksp=bart('fft 7',bartnufft); 

figure(5)
subplot(211)
imshow(abs(squeeze(griddedksp(:,:,:,25))),[])
subplot(212)
imshow(imag(squeeze(griddedksp(:,:,:,25))),[])