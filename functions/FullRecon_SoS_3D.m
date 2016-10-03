function [MR,P]=FullRecon_SoS_3D(P)
P=checkGAParams(P);

switch P.type3D
    case 1
        disp('3D reconstruction using MCNUFFT operator')
        MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
        [MR,P] = UpdateReadParamsMR(MR,P);
        
        if P.sensitivitymaps == true
            OutputSizeSensitivity=P.reconresolution; %what if data is not same length as this resolution??
            P.senseLargeOutput=1;
            run FullRecon_SoS_sense.m;
        end
        
        MR.Perform1;    %reading and sorting data
        MR.CalculateAngles;
        MR.PhaseShift;
        [nx,ntviews,nz,nc]=size(MR.Data);
        goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
        k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);
%         wu=calcDCF(k,MR.Parameter.Encoding.XReconRes);
        wu=getRadWeightsGA(k);
        kdata=ifft(MR.Data,[],3);
        
        for selectslice=P.reconslices
            selectslice
            sensmap=conj(squeeze(sens(:,:,selectslice-P.reconslices(1)+1,:)));
            tempy=double(squeeze(kdata(:,:,selectslice,:))).*permute(repmat(sqrt(wu),[1 1 1 nc]),[1 2 4 3]);
            tempE=MCNUFFT(k,sqrt(wu),squeeze(sensmap)); %initialize NUFFT gridding operator
            recon(:,:,selectslice)=(tempE'*tempy);
            if true
                cd(P.resultsfolder)
                voxelsize=MR.Parameter.Scan.AcqVoxelSize
                nii=make_nii(abs(permute(flip(squeeze(recon),1),[2 1 3 4 5])),voxelsize,[],[],'');
                save_nii(nii,strcat(P.filename,'.nii'))
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
    case 2 %MRECON GRIDDING
        disp('MRECON GRIDDING')
        MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
        if P.sensitivitymaps == true
            run FullRecon_SoS_sense.m;
        end
        [MR,P] = UpdateReadParamsMR(MR,P);
        MR.Parameter.Recon.Sensitivities=MR_sense;
        MR.Perform;
        if true
            cd(P.resultsfolder)
            voxelsize=MR.Parameter.Scan.AcqVoxelSize
            nii=make_nii(abs(permute(flip(squeeze(MR.Data),1),[2 1 3 4 5])),voxelsize,[],[],'');
            save_nii(nii,strcat(P.filename,'.nii'))
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 3  %BART CG SENSE
        
        disp('3D reconstruction using BART operator')
        MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
        [MR,P] = UpdateReadParamsMR(MR,P);
        
        P.sensitvitymapscalc='espirit'
        %     if P.sensitivitymaps == true
        %         P.senseLargeOutput=1;
        %         run FullRecon_SoS_sense.m;
        %     end
        
        MR.Perform1;    %reading and sorting data
        MR.CalculateAngles;
        MR.PhaseShift;
        [nx,ntviews,nz,nc]=size(MR.Data);
        goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
        k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);
        kdata=ifft(MR.Data,[],3);
        res=MR.Parameter.Encoding.XRes(1);
        coordsfull=RadTraj2BartCoords(k,res);
        reco_cs=zeros(res,res,length(P.reconslices));
        
        for slice=P.reconslices
            slice
            fprintf('Recon slice %d of %d.',slice,size(kdata,3))
            ksp_acq=(kdata(:,:,slice,:));
            ksp_acq_t=permute(ksp_acq,[3 1 2 4]);
            
            if strcmp(P.sensitvitymapscalc,'sense')==1
                sensbart=conj(sens(:,:,slice,:));
            elseif strcmp(P.sensitvitymapscalc,'espirit')==1
                nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
                lowres_ksp=bart('fft -u 7',nufft);
                sensoptions=['ecalib -r25 -S -m',num2str(P.espiritoptions.nmaps)];
                sensbart=bart(sensoptions,lowres_ksp);
            end
            
                bartoptions=['pics -S -d5 -RT:7:0:',num2str(P.CS.reg), ' -i',num2str(P.CS.iter),' -t'];
                                bartoptions=['pics -S -d5 -i100 -t'];

                dummy=bart(bartoptions, coordsfull, ksp_acq_t, sensbart);
                dummy=bart('rss 16',dummy);
                reco_cs(:,:,slice,:)=squeeze(dummy);
            
%             bartoptions=['nufft -i -t -l0.01'];
%             dummy=bart(bartoptions, coordsfull, ksp_acq_t);
%             dummy=dummy.*sensbart;
%             dummy=bart('rss 8',dummy);
%             reco_cs(:,:,slice,:)=squeeze(dummy);
            
            if true
                cd(P.resultsfolder)
                voxelsize=MR.Parameter.Scan.AcqVoxelSize
                nii=make_nii(abs(permute(flip(squeeze(reco_cs),1),[2 1 3 4 5])),voxelsize,[],[],'');
                save_nii(nii,strcat(P.filename,'.nii'))
            end
            
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         case 4  %BART CG SENSE 3D
        
        disp('3D reconstruction using BART operator')
        MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
        [MR,P] = UpdateReadParamsMR(MR,P);
        
        P.sensitvitymapscalc='espirit'
        %     if P.sensitivitymaps == true
        %         P.senseLargeOutput=1;
        %         run FullRecon_SoS_sense.m;
        %     end
        
        MR.Perform1;    %reading and sorting data
        MR.CalculateAngles;
        MR.PhaseShift;
        [nx,ntviews,nz,nc]=size(MR.Data);
        goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
        k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);
        kdata=ifft(MR.Data,[],3);
        res=MR.Parameter.Encoding.XRes(1);
        coordsfull=RadTraj2BartCoords(k,res);
        reco_cs=zeros(res,res,length(P.reconslices));
        
        for slice=P.reconslices
            slice
            fprintf('Recon slice %d of %d.',slice,size(kdata,3))
            ksp_acq=(kdata(:,:,slice,:));
            ksp_acq_t=permute(ksp_acq,[3 1 2 4]);
            
            if strcmp(P.sensitvitymapscalc,'sense')==1
                sensbart=conj(sens(:,:,slice,:));
            elseif strcmp(P.sensitvitymapscalc,'espirit')==1
                nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
                lowres_ksp=bart('fft -u 7',nufft);
                sensoptions=['ecalib -r25 -S -m',num2str(P.espiritoptions.nmaps)];
                sensbart=bart(sensoptions,lowres_ksp);
            end
            
            %     bartoptions=['pics -S -d5 -RT:7:0:',num2str(P.CS.reg), ' -i',num2str(P.CS.iter),' -t'];
            %     dummy=bart(bartoptions, coordsfull, ksp_acq_t, sensbart);
            %     dummy=bart('rss 16',dummy);
            %     reco_cs(:,:,slice,:)=squeeze(dummy);
            
            bartoptions=['nufft -i -t -l0.01'];
            dummy=bart(bartoptions, coordsfull, ksp_acq_t);
            dummy=dummy.*sensbart
            dummy=bart('rss 8',dummy);
            reco_cs(:,:,slice,:)=squeeze(dummy);
            
            if true
                cd(P.resultsfolder)
                voxelsize=MR.Parameter.Scan.AcqVoxelSize
                nii=make_nii(abs(permute(flip(squeeze(reco_cs),1),[2 1 3 4 5])),voxelsize,[],[],'');
                save_nii(nii,strcat(P.filename,'.nii'))
            end
            
        end
        
        
end

end