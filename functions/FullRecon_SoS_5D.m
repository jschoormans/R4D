function [MR,P]=FullRecon_SoS_5D(P)

[MR,P,ku,kdatau,k]=FullRecon_SoS_4D_init(P);

%% BART CS
res=MR.Parameter.Encoding.XRes(1);
pause(5);
coords=RadTraj2BartCoords(ku,res);
coordsfull=RadTraj2BartCoords(k,res);
%
for slice=P.reconslices
    fprintf('Recon slice %d of %d.',slice,size(kdatau,3))
    ksp_acq=(kdatau(:,:,slice,:,:));
    ksp_acq_t=permute(ksp_acq,[3 1 2 4 6 7 8 9 10 11 5]);
    
    if strcmp(P.sensitvitymapscalc,'sense')==1
        sensbart=conj(sens(:,:,slice,:));
    elseif strcmp(P.sensitvitymapscalc,'espirit')==1
        if P.dynamicespirit==true
            nufft=bart('nufft -i -t',coords,ksp_acq_t);
            lowres_ksp=bart('fft -u 7',nufft);
            for t=1:size(ksp_acq_t,11)
                sensbart(:,:,:,:,t)=bart('ecalib -r15 -S -m1',lowres_ksp);
            end
            sensbart=permute(sensbart,[1 2 3 4 6 7 8 9 10 11 5]);
            nufftcc(:,:,slice,:)=bart('rss 8',nufft.*sensbart); %combine coils for nufft recon
        else
            nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
            lowres_ksp=bart('fft -u 7',nufft);
            sensbart=bart('ecalib -r15 -S -m1',lowres_ksp);
            nufftcc=bart('rss 8',nufft.*sensbart); %combine coils for nufft recon
        end
    else
        error('Error: sensitvity maps calculation unknown/not recognized')
    end
        
    bartoptions=['pics -S -d5 -RT:1024:0:',num2str(P.CS.reg), ' -i',num2str(P.CS.iter),' -t'];
    reco_cs(:,:,slice,:,:,:,:,:,:,:,:) = bart(bartoptions, coords, ksp_acq_t, sensbart);
%   reco_cs=bart('rss 8',reco_cs);


    if true
        cd(P.resultsfolder)
        voxelsize=MR.Parameter.Scan.AcqVoxelSize
        nii=make_nii(abs(permute(flip(squeeze(reco_cs),1),[2 1 3 4 5])),voxelsize,[],[],'');
        save_nii(nii,strcat(P.filename,'.nii'))

        nii=make_nii(abs(permute(flip(squeeze(nufftcc),1),[2 1 3 4 5])),voxelsize,[],[],'');
        save_nii(nii,strcat(P.filename,'NUFFT.nii'))
    end


end

end