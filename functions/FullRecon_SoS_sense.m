% FullRecon_SoS_sense
switch P.sensitvitymapscalc
    case 'sense'
        disp('Initializing MRSense...')
        MRref=MRecon(fullfile(P.folder,P.sense_ref));
        MRsurvey=MRecon(fullfile(P.folder,P.coil_survey));
        MR_sense = MRsense(MRref,MR,MRsurvey); %for now use standard settings...
%         MR_sense.Smooth=1;
%         MR_sense.Extrapolate=1;
%         MR_sense.Mask=1;
        if P.senseLargeOutput==1; %make sense maps larger
            OutputSizeSensitivity=[MR.Parameter.Encoding.XReconRes,MR.Parameter.Encoding.YReconRes,MR.Parameter.Encoding.ZReconRes];
            MR_sense.Rotate=0;
            MR_sense.MatchTargetSize=1;
            MR_sense.OutputSizeReformated=OutputSizeSensitivity; %give option to choose these?
            MR_sense.OutputSizeSensitivity=OutputSizeSensitivity;
        end
        disp('Calculating coil sensitivities...')
        MR_sense.Perform;
        
        %add stuff here so that Coil Combine uses sense maps
        MR.Parameter.Recon.ImageSpaceZeroFill = 'no';
        MR.Parameter.Recon.RemovePOversampling = 'no';
        MR.Parameter.Recon.CoilCombination = 'no';

        MR.Parameter.Recon.Sensitivities=MR_sense;
        MR.Parameter.Recon.SENSERegStrength=0; %not sure about these things though...
    case 'espirit'
        %todo...
        res=MR.Parameter.Encoding.XReconRes;
        clear coords
        coords(1,:,:,:)=real((k(:,:,:))).*res;
        coords(2,:,:,:)=imag((k(:,:,:))).*res;
        coords(3,:,:,:)=zeros(size(k(:,:,:)));
        size(coords)
        
        for sl=1:ny
            ksp2_permuted=permute(MR.Data(:,:,sl,:),[3 1 2 4]); %PERMUTE STACK OF STARS KSPACE
            Im2=bart('nufft -i -t -d24:24:1',coords,ksp2_permuted);
            
            ksp_lowres=bart('fft -u 6',Im2);
            ksp_lowres=permute(ksp_lowres,[3 1 2 4]);
            
            ksp_zerop=padarray(ksp_lowres,[0 (res-24)/2 (res-24)/2 0]); disp('automate resolution of sens maps')
            sensbart(:,:,sl,:)=(bart('ecalib -m1',(ksp_zerop)));
            sens(:,:,sl,:)=conj(sensbart(:,:,sl,:));
            disp(strcat(num2str(sl),'/',num2str(ny)))
        end
end
