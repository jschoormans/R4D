function [MR,P]=FullRecon_SoS_5D(P)
P=checkGAParams(P);
MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);

P.nEchoes=MR.Parameter.Encoding.NrEchoes;
res=MR.Parameter.Encoding.XRes(1);
reco_cs=zeros(res,res,length(P.reconslices),P.binparams.nBins,P.nEchoes);

echo_sens = 0; % calculate separate sens maps for the echos

for TE=1:P.nEchoes
    P.TE=TE;
    [MR,P,ku,kdatau,k]=FullRecon_SoS_5D_init(P);
    
    if (echo_sens == 1) %pdh original code
        %% BART CS
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
                    %             dummy=squeeze(bart('rss 8',nufft.*sensbart)); %combine coils for nufft recon
                    %             nufftcc(:,:,slice,:)=permute(dummy,[1 2 4 3]);
                else
                    nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
                    lowres_ksp=bart('fft -u 7',nufft);
                    sensbart=bart('ecalib -r15 -S -m1',lowres_ksp);
                    %             nufftcc=bart('rss 8',nufft.*sensbart); %combine coils for nufft recon
                end
            else
                error('Error: sensitvity maps calculation unknown/not recognized')
            end
            
            bartoptions=['pics -S -d5 -RT:1024:0:',num2str(P.CS.reg), ' -i',num2str(P.CS.iter),' -t'];
            reco_cs(:,:,slice,:,TE) = squeeze(bart(bartoptions, coords, ksp_acq_t, sensbart));
            %   reco_cs=bart('rss 8',reco_cs);
            
            if true
                cd(P.resultsfolder)
                voxelsize=MR.Parameter.Scan.AcqVoxelSize
                nii=make_nii(abs(permute(flip(squeeze(reco_cs),1),[2 1 3 4 5])),voxelsize,[],[],'');
                save_nii(nii,strcat(P.filename,'.nii'))
                
                %         nii=make_nii(abs(permute(flip(squeeze(nufftcc),1),[2 1 3 4 5])),voxelsize,[],[],'');
                %         save_nii(nii,strcat(P.filename,'NUFFT.nii'))
            end
            
        end
    else
        %% BART CS
        pause(5);
        coords=RadTraj2BartCoords(ku,res);
        coordsfull=RadTraj2BartCoords(k,res);
        
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
                    %             dummy=squeeze(bart('rss 8',nufft.*sensbart)); %combine coils for nufft recon
                    %             nufftcc(:,:,slice,:)=permute(dummy,[1 2 4 3]);
                else
                    if (echo_sens == 1 || TE == 1) %pdh added if statement
                        
                        nufft=bart('nufft -i -t',coordsfull,permute(MR.Data(:,:,slice,:),[3 1 2 4]));
                        lowres_ksp=bart('fft -u 7',nufft);
                        sensbart=bart('ecalib -r15 -S -m1',lowres_ksp);
                        %             nufftcc=bart('rss 8',nufft.*sensbart); %combine coils for nufft recon
                        % 19-10-2016 pdh Added to check the masking  of the
                        % reconstruction. Most likely the later echos have to little
                        % signal to accurately make a mask. Might be best to make a
                        % mask with just the first echo
                        if TE == 1
                            temp.sensbart_echo1(:,:,:,:,slice) = sensbart;
                        end
                    elseif (echo_sens == 0 && TE > 1)
                        sensbart = temp.sensbart_echo1(:,:,:,:,slice);
                    end
                end
            else
                error('Error: sensitvity maps calculation unknown/not recognized')
            end

            bartoptions=['pics -S -d5 -RT:1024:0:',num2str(P.CS.reg), ' -i',num2str(P.CS.iter),' -t'];
            reco_cs(:,:,slice,:,TE) = squeeze(bart(bartoptions, coords, ksp_acq_t, sensbart));
            %   reco_cs=bart('rss 8',reco_cs);
            %             reco_cs(:,:,slice,:,TE) = reco_cs(:,:,slice,:,1); % set to the value of the first echo
            
            if true
                cd(P.resultsfolder)
                voxelsize=MR.Parameter.Scan.AcqVoxelSize
                nii=make_nii(abs(permute(flip(squeeze(reco_cs),1),[2 1 3 4 5])),voxelsize,[],[],'');
                save_nii(nii,strcat(P.filename,'.nii'))
                
                %         nii=make_nii(abs(permute(flip(squeeze(nufftcc),1),[2 1 3 4 5])),voxelsize,[],[],'');
                %         save_nii(nii,strcat(P.filename,'NUFFT.nii'))
            end
            
        end
        
    end
    
end