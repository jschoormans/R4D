% FullRecon_SoS_sense
%code that calculates the sense maps for SoS radial scans - either using
%coil survey scans or sense ref scans

switch P.sensitvitymapscalc
    case 'sense2'
        
        disp('using SENSE maps...')
            
            tic
            MR2=GoldenAngle_Recon(strcat(P.folder,P.file));
            MR2.Parameter.Parameter2Read.ky=[0:1:200]'; %not necessary to load all data;
            MR2.Perform1; MR2.PerformGrid;
            MR2.RemoveOversampling; 
            toc

            %MR2.RemoveOversampling;
%             MR_sense = MRsense(sense_ref,MR2,coil_survey);
            MR_sense = MRsense([P.folder,P.coil_survey],MR2);
            MR_sense.Smooth=1;
            MR_sense.Extrapolate=1;
            MR_sense.Mask=1;
            MR_sense.Rotate=0;
            MR_sense.MatchTargetSize=1;
            %MR_sense.RemoveMOversampling=1;
            MR_sense.OutputSizeReformated=OutputSizeSensitivity;
            MR_sense.OutputSizeSensitivity=OutputSizeSensitivity;
            disp('MRSense Perform...')
            MR_sense.Perform;
            sens=conj(flipdim(MR_sense.Sensitivity,1));
            sens=double(sens);%./max(sens(:));
            clear MR2; clear MR_sense;
    
    case 'sense'
        disp('Initializing MRSense...')
        MRref=MRecon(fullfile(P.folder,P.sense_ref));        
        MRsurvey=MRecon(fullfile(P.folder,P.coil_survey));
        
        %set oversampling to 1 & save
        KxO=MR.Parameter.Encoding.KxOversampling;
        KyO=MR.Parameter.Encoding.KyOversampling;
        MR.Parameter.Encoding.KxOversampling=1;
        MR.Parameter.Encoding.KyOversampling=1;
        
        MR_sense = MRsense(MRref,MR,MRsurvey); %for now use standard settings...
        MR_sense.Smooth=1;
        MR_sense.Extrapolate=1;
        MR_sense.Mask=0;
        if P.senseLargeOutput==1; %make sense maps larger
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
        sens=conj(flipdim(MR_sense.Sensitivity,1));
        sens=double(sens);%./max(sens(:));
        
        %set oversampling factors back to originals;;;
        MR.Parameter.Encoding.KxOversampling=KxO;
        MR.Parameter.Encoding.KyOversampling=KyO;
        %clear oversampliing factor params
        clear KxO KyO
        
        if P.debug>0;
           figure(551)
           R=[];
           for iii=1:size(sens,4);
               R=cat(2,R,squeeze(sens(:,:,floor(size(sens,3)/2),iii)));
           end
           imshow(abs(R),[]); title('sens maps')
            
        end

        
    case 'espirit'
        [nx,ntviews,ny,nc]=size(MR.Data);
        k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
        res=MR.Parameter.Encoding.XReconRes;
        clear coords
        coords(1,:,:,:)=real((k(:,:,:))).*res;
        coords(2,:,:,:)=imag((k(:,:,:))).*res;
        coords(3,:,:,:)=zeros(size(k(:,:,:)));
        size(coords)
        
        for sl=P.reconslices
            ksp2_permuted=permute(MR.Data(:,:,sl,:),[3 1 2 4]); %PERMUTE STACK OF STARS KSPACE
            Im2=bart('nufft -i -t -d24:24:1',coords,ksp2_permuted);
            
            ksp_lowres=bart('fft -u 6',Im2);
            ksp_lowres=permute(ksp_lowres,[3 1 2 4]);
            
            ksp_zerop=padarray(ksp_lowres,[0 (res-24)/2 (res-24)/2 0]); disp('automate resolution of sens maps')
            sensbart(:,:,sl,:)=(bart('ecalib -m1',(ksp_zerop)));
            sens(:,:,sl,:)=conj(sensbart(:,:,sl,:));
            disp(strcat(num2str(sl),'/',num2str(ny)))
        end
        
    case 'openadapt'
        res=MR.Parameter.Encoding.XReconRes;

        
        kdata=squeeze(MR.Data); %select kdata for slice
        w=getRadWeightsGA(k);
        weighted_data=bsxfun(@times,kdata,sqrt(w));
        NUFFTOP=NUFFT(k,sqrt(w),1,0,[res res],2);

        fprintf('calculating separate coil/slice images for openadapt...\n')
        tic
        for selectslice=P.reconslices       % sort the data into a time-series
            fprintf('%d - ',selectslice)
            for selectcoil=[1:size(kdata,4)]
                zerofill(:,:,selectslice,selectcoil)=NUFFTOP'*double(kdata(:,:,selectslice,selectcoil));
            end
        end
        toc
        
        fprintf('Running openadapt...\n')
        [~, ~, sens] = openadapt(zerofill);
        fprintf('Finished.\n')

        
      % to do..
end
