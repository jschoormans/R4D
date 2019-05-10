[V, SPATIAL, DIM] = dicomreadVolume('L:\basic\divi\Projects\dcerecon\MRI\raw\1299_GRASP_phantom_fat\20190403_1.3.46.670589.11.42151.5.0.6648.2019040314133853000\MR\01903_DelRec_-_DCE_liver_SOS_3.5mm_GA_lohi')
%%
clear Im
for ii=1:26
Im(:,:,:,ii)=V(:,:,1,ii:26:end);
end
%
imagine(squeeze(Im(:,:,:,1)),squeeze(Im(:,:,:,2)),squeeze(Im(:,:,:,3)),squeeze(Im(:,:,:,4)),...
    squeeze(Im(:,:,:,23)),squeeze(Im(:,:,:,24)),squeeze(Im(:,:,:,25)),squeeze(Im(:,:,:,26)),squeeze(Im(:,:,:,10)))
%%
imagine(squeeze(Im(:,:,:,10)),squeeze(Im(:,:,:,11)),squeeze(Im(:,:,:,12)),squeeze(Im(:,:,:,13)),...
    squeeze(Im(:,:,:,23)),squeeze(Im(:,:,:,24)),squeeze(Im(:,:,:,25)),squeeze(Im(:,:,:,26)),squeeze(Im(:,:,:,10)))



%% KSPACE

[K, SPATIAL, DIM] = dicomreadVolume('L:\basic\divi\Projects\dcerecon\MRI\raw\1299_GRASP_phantom_fat\20190403_1.3.46.670589.11.42151.5.0.6648.2019040314133853000\MR\01904_DelRec_-_DCE_liver_SOS_3.5mm_GA_lohi');
%
clear k
for ii=1:26
k(:,:,:,ii)=K(:,:,1,ii:26:end);
end
%%
imagine(squeeze(k(:,:,:,1)),squeeze(k(:,:,:,2)),squeeze(k(:,:,:,3)),squeeze(k(:,:,:,4)),...
    squeeze(k(:,:,:,23)),squeeze(k(:,:,:,24)),squeeze(k(:,:,:,25)),squeeze(k(:,:,:,26)),squeeze(k(:,:,:,10)))
