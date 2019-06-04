% test 
cd('/home/jschoormans/lood_storage/divi/Ima/parrec/jhrunge/Studies/DCErecon/Test_12FEB2019/2019_02_12/dc_35509/')
MR=GoldenAngle_Recon('dc_12022019_1854289_3_2_dce_liver_sos_3.5mmV4.raw')
MR.Perform1;                        %reading and sorting data
MR.CalculateAngles
%%
Data2=fftshift(ifft(ifftshift(MR.Data,3),[],3),3);
%%
figure(11)
imshow(squeeze(abs(MR.Data(128,1:100,1:100,1))),[]);

figure(12)
imshow(squeeze(abs(Data2(128,1:100,1:100,25))),[]);


%% proper data  (ifft with shifts)
% grid Data that has been ifftéd properly.(with shift) 

traj=bart('traj -r -G -x512 -y1280');

ksp=Data2(:,1:1280,90,:);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
bartnufft=bart('nufft -i -t',traj(:,:,1:1:1280),ksp);

ncoils=size(Data2,4)
for c=1:ncoils    
    figure(1); imshow(abs(squeeze(bartnufft(:,:,:,c))),[]);
    pause(0.3)
end

figure(1); imshow(abs(squeeze(bartnufft(:,:,1,25))),[]);
title('RSS coil combination')

%% copy symmetric data
Data3=MR.Data;
Data3(:,:,1:30,:)=(Data3(:,:,100:-1:71,:));

figure(20)
imshow(abs(squeeze(Data3(256,1:100,:,25))),[]);


Data3=fftshift(ifft(ifftshift(Data3,3),[],3),3);

traj=bart('traj -r -G -x512 -y1280');

ksp=Data3(:,1:1280,30,:);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
bartnufft=bart('nufft -i -t',traj(:,:,1:1:1280),ksp);

ncoils=size(Data3,4)
for c=1:ncoils    
    figure(21); imshow(abs(squeeze(bartnufft(:,:,:,c))),[]);
    pause(0.3)
end


%% first: remove entire first half of data
Data3=MR.Data;;
Data3(:,:,1:50,:)=0;

figure(20)
imshow(abs(squeeze(Data3(256,1:100,:,25))),[]);


Data3=fftshift(ifft(ifftshift(Data3,3),[],3),3);

traj=bart('traj -r -G -x512 -y1280');

ksp=Data3(:,1:1280,90,:);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
bartnufft=bart('nufft -i -t',traj(:,:,1:1:1280),ksp);

figure(1); imshow(abs(squeeze(bartnufft(:,:,1,25))),[]);

%% remove second half of data
Data3=MR.Data;;
Data3(:,:,51:100,:)=0;

Data3=fftshift(ifft(ifftshift(Data3,3),[],3),3);

traj=bart('traj -r -G -x512 -y1280');

ksp=Data3(:,1:1280,90,:);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
bartnufft=bart('nufft -i -t',traj(:,:,1:1:1280),ksp);

figure(1); imshow(abs(squeeze(bartnufft(:,:,1,25))),[]);


ncoils=size(Data3,4)
for c=1:ncoils    
    figure(21); imshow(abs(squeeze(bartnufft(:,:,:,c))),[]);
    pause(0.3)
end


%% remove last 30% of data...
Data3=MR.Data;;
Data3(:,:,1:75,:)=0;

figure(20)
imshow(abs(squeeze(Data3(256,1:100,:,25))),[]);


Data3=fftshift(ifft(ifftshift(Data3,3),[],3),3);

traj=bart('traj -r -G -x512 -y1280');

ksp=Data3(:,1:128,25,:);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
bartnufft=bart('nufft -i -t',traj(:,:,1:1:128),ksp);
figure(1); imshow(abs(squeeze(bartnufft(:,:,1,25))),[0 10]);


ncoils=size(Data3,4)
for c=1:ncoils    
    figure(21); imshow(abs(squeeze(bartnufft(:,:,:,c))),[]);
    pause(0.3)
end


%% taking another look at the intensities / conj symmetry 
figure(20)
plot(abs(squeeze(MR.Data(256,1,:,25))));
title('k-space centers for stack 1 (angle 0), coil 25')

figure(21)
plot(abs(mean(squeeze(MR.Data(256,1:100,:,25)),1)));
title('k-space centers for stack 1-100 (mean) (angle 0), coil 25')



%%
%4 april 2018

slice=69;
data=MR.Data(:,:,slice,25); 

[~,idx]=sort(mod(MR.Parameter.Gridder.RadialAngles,2*pi));

figure(20); 
imshow(abs(data(:,idx)),[0 200]);
xlabel('sorted angles')
ylabel('readout')
title('kz=69')

data=MR.Data(:,idx(1100),:,25); 
figure(21); 
imshow(abs(data(:,:)),[0 200]);
xlabel('slice encoding')
ylabel('readout')
title('stack of spokes')

data=MR.Data(100,idx,:,25); 
figure(22); 
imshow(abs(squeeze(data)).',[0 200]);
ylabel('slice encoding')
xlabel('sorted angles')
title('readout kx=100')


%%  only grid first half of readout...
%4april 2018 
Data3=MR.Data;

figure(20)
imshow(abs(squeeze(Data3(256,1:100,:,25))),[]);


Data3=fftshift(ifft(ifftshift(Data3,3),[],3),3);

traj=bart('traj -r -G -x512 -y1280');

%%

c=25

for sl=10:10:100
    sl
    ksp=Data3(1:270,1:1000,sl,c);
    ksp=permute(ksp,[3 1 2 4]);
    size(ksp)
    bartnufft_first_half(:,:,sl)=bart('nufft -i -t',traj(:,1:270,1:1:1000),ksp);
    
    ksp=Data3(1:512,1:1000,sl,c);
    ksp=permute(ksp,[3 1 2 4]);
    size(ksp)
    bartnufft_all(:,:,sl)=bart('nufft -i -t',traj(:,1:512,1:1:1000),ksp);

end


figure(21); subplot(211); imshow(abs(squeeze(bartnufft_first_half(:,:,sl))),[]);
title('gridded first half of readout only')

subplot(212);  imshow(abs(squeeze(bartnufft_all(:,:,sl))),[]);
title('gridded all readout')


first_half_gridksp=bart('fft 7',bartnufft_first_half(:,:,sl));
all_gridksp=bart('fft 7',bartnufft_all(:,:,sl));

figure(22);
subplot(211); 
title('gridded kspace of first half of readout only')
imshow(abs(squeeze(first_half_gridksp)),[0 20000])
subplot(212); 
title('gridded kspace of all readout')
imshow(abs(squeeze(all_gridksp)),[0 20000])
%%
imagine(bartnufft_first_half(:,:,10:10:100),bartnufft_all(:,:,10:10:100))

%%
c=25

sl=80
ksp=Data3(1:270,1:1000,sl,c);
ksp=permute(ksp,[3 1 2 4]);
size(ksp)
temp=bart('nufft -i -t',traj(:,1:270,1:1:10),ksp);


figure(21); imshow(abs(squeeze(temp)),[]);
title('gridded first half of readout only')


