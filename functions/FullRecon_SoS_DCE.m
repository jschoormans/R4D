function [MR,P]=FullRecon_SoS_DCE(P)
% DCE GOLDEN ANGLE RECONSTRUCTION
P=checkGAParams(P);

MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);  %update read paramters based on MR object params

MR.Perform1;                        %reading and sorting data
MR.CalculateAngles; 
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3);         %eventually: remove slice oversampling

[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);


if P.sensitivitymaps == true
    if strcmp(P.sensitvitymapscalc,'sense')==1|strcmp(P.sensitvitymapscalc,'sense2')==1
            P.senseLargeOutput=1;
            OutputSizeSensitivity=P.reconresolution; %what if data is not same length as this resolution??
            run FullRecon_SoS_sense.m;
%             sens=MR_sense.Sensitivity; %??
            clear MR_sense;
    elseif strcmp(P.sensitvitymapscalc,'espirit')==1|strcmp(P.sensitvitymapscalc,'openadapt')
        run FullRecon_SoS_sense.m;
    else
       error('unknown sensitivity calculation method!') 
    end
else
    error('sense maps needed for DCE recons!')
end

%%%SORTING
kdata=squeeze(MR.Data(:,:,:,:,1)); %select kdata for slice
nt=floor(ntviews/P.DCEparams.nspokes);              % calculate (max) number of frames
kdatac=kdata(:,1:nt*P.DCEparams.nspokes,:,:);       % crop the data according to the number of spokes per frame


%%
for ii=1:nt       % sort the data into a time-series 
    kdatau(:,:,:,:,ii)=kdatac(:,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes,:,:); %kdatau now (nfe nspoke nslice nc nt)
    ku(:,:,ii)=double(k(:,(ii-1)*P.DCEparams.nspokes+1:ii*P.DCEparams.nspokes));
end

wu=getRadWeightsGA(ku);
clear kdatac kdata %clear memory

%% get first guess 
disp('First guess')
for selectslice=P.reconslices       % sort the data into a time-series 
    fprintf('%d - ',selectslice)
    tempy=squeeze(double(kdatau(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
    tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
    R(:,:,selectslice,:)=(tempE'*tempy); %first guess
end
R(isnan(R))=0;

%%  L1 minimization algorithm (NLCG)
    
P.DCEparams.lambda = 0.25*max(abs(R(:))); 
for selectslice=P.reconslices;     %to do: CHANGE TO RELEVANT SLICES OMNLY
    
    tempy=squeeze(double(kdatau(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
    
    if ~P.GPU 
        tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
    else 
        disp('Generate GPU NUFFT Operator');
        osf = 2; % oversampling: 1.5 1.25
        wg = 3; % kernel width: 5 7
        sw = 12; % parallel sectors' width: 12 16
        res = size(sens,1); 
        
        w=getRadWeightsGA(ku);
        tempE = MDgpuNUFFT(ku,w,osf,wg,sw,[res,res,1],[],true);
        
        
    end
    
    
    fprintf('\n GRASP reconstruction slice: %i of %i \n',selectslice,P.reconslices(end))
    
    res=squeeze(R(:,:,selectslice,:));
    for outeriter=1:P.DCEparams.outeriter
        res=CSL1NlCg_experimental(res,P.DCEparams,tempy,tempE,selectslice); 
    end
    recon_cs(:,:,selectslice,:) = res;
    
    voxelsize=MR.Parameter.Scan.AcqVoxelSize
    description='description'
    cd(P.resultsfolder)
    nii=make_nii(squeeze(abs(flip((permute(recon_cs(:,:,P.reconslices(1):selectslice,:),[2 1 3 4]))))),voxelsize,[],[],description);
    save_nii(nii,strcat(P.filename,'CS_N_FR','.nii'))
    
end


end
