%% EXAMPLE SCRIPT FOR A 4D RECONSTRUCTION

clear all; close all; clc;
addpath(genpath('/scratch/jschoormans/R4D/General_Code'));
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/nifti'))
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab_Collection/imagine'))


P=struct
%% PARAMETERS

P.sensitvitymapscalc='espirit'
P.dynamicespirit=false


%% RECONSTRUCTION IN STEPS
cd('/home/jschoormans/lood_storage/divi/Ima/parrec/jschoormans/20190729_lever_freebreathing')
P=checkGAParams(P);
MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MR.Perform1;    %reading and sorting data
MR.CalculateAngles;
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3); %eventually: remove slice oversampling
[nx,ntviews,ny,nc]=size(MR.Data);
goldenangle=MR.Parameter.GetValue('`CSC_golden_angle');
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);


%% do binning
close all
TR=MR.Parameter.Scan.TR;
halfscan=MR.Parameter.Scan.HalfScanFactors(2);

P.binparams.smoothingmethod='none'
P.binparams.smoothspan=25; %value for MA-filter
P.binparams.visualize =1;
P.binparams.sortingmethod='v2'  %method of sorting the gating_singal: p=phase; v=value
P.binparams.nBins=6;%number of bins in which to sort the k-space
P.binparams.PCAfreqband=[0.1 0.2] 
P.binparams.gatingmethod='PCA'



P.binparams.Fs=(size(MR.Data,3)*halfscan*TR*1e-3)^(-1); %!!!
P.binparams.goldenangle=MR.Parameter.GetValue('`CSC_golden_angle');
P.binparams.PCAfreqband=[0.1 0.5]
P.binparams.sortingmethod='v'
% P.binparams.gatingnz=[1:10]
% P.binparams.gatingchans=[1:23]
[kdatau,ku] = ksp2frames(MR.Data,k,P.binparams);

%% DO CS
%% BART CS
res=MR.Parameter.Encoding.XRes;
pause(5);
coords=RadTraj2BartCoords(ku,res);
coordsfull=RadTraj2BartCoords(k,res);
%
parfor slice=1:size(MR.Data,3)
    fprintf('Recon slice %d of %d.',slice,size(kdatau,3))
    ksp_acq=(kdatau(:,:,slice,:,:));
    ksp_acq_t=permute(ksp_acq,[3 1 2 4 6 7 8 9 10 11 5]);
    
    nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
    lowres_ksp=bart('fft -u 7',nufft);
    sensbart=bart('ecalib -r15 -m1',lowres_ksp);
    nufftcc(:,:,slice,:)=bart('rss 8',nufft.*sensbart); %combine coils for nufft recon
end

if true
    cd(P.resultsfolder)
    voxelsize=MR.Parameter.Scan.AcqVoxelSize
    
    nii=make_nii(abs(permute(flip(squeeze(nufftcc),1),[2 1 3 4 5])),voxelsize,[],[],'');
    save_nii(nii,strcat(P.filename,'NUFFT_all.nii'))
end

%%
clear nufftcc_small

clear slice
pad=120
nufftcc_small=nufftcc(pad:end-pad,pad:end-pad,:); 

nufftcc_small=abs(nufftcc_small);
nufftcc_small=nufftcc_small/1;%/(eps+prctile(abs(nufftcc_small(:)),1));
corr=linspace(1,-1,size(nufftcc_small,3)); 
corr=abs(1-abs(corr))
corr=permute(corr,[1 3 2]); 
size(corr)
nufftcc_small=bsxfun(@mtimes,nufftcc_small,corr); 

X=[1:size(nufftcc_small,1)]';
Y=X;
Z=[1:size(nufftcc_small,3)].*2;

f1=figure(1)
set(gcf,'color','White')

h=slice(X,Y,Z,abs(nufftcc_small),[60],[40],[100],'linear')
grid off
xticks([])
yticks([])
zticks([])

set(h,'edgecolor','none')
set(h,'FaceAlpha',1)
set(h,'CDataMapping','direct' )

colormap('gray')




