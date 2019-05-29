function [MR,P]=FullRecon_SoS_DCE(P)
% DCE GOLDEN ANGLE RECONSTRUCTION
P=checkGAParams(P);

MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);  %update read paramters based on MR object params
run LoadMR.m %loads previous MR file if it exists

if P.isLoaded==0    
    MR.Perform1;                        %reading and sorting data
    MR.CalculateAngles;
    MR.PhaseShift;
    MR.Data=ifft(MR.Data,[],3);         %eventually: remove slice oversampling
end

run SaveMR
%%
[nx,ntviews,ny,nc]=size(MR.Data);
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],P.goldenangle);
%%
if P.prewhiten
    fprintf('Prewhitening...')
    
    MRn=MR.Copy; MRn.Parameter.Parameter2Read.typ=5;
    MRn.Parameter.Parameter2Read.echo=0;
    MRn.ReadData;
    P.eta=MRn.Data;
    
    sizeMRDATA=size(MR.Data);
    Ncoils=size(MR.Data,4);
    Nsamples=numel(MR.Data)/Ncoils;
    data=reshape(MR.Data,[Nsamples,Ncoils]);
    data=data.';
    
    psi = (1/(Nsamples-1))*(P.eta' * P.eta);
    L = chol(psi,'lower');
    L_inv = inv(L);
    data_corr = conj(L_inv) * data;
    data_corr=data_corr.';
    MR.Data=reshape(data_corr,sizeMRDATA);
    fprintf('Finished\n')
end
%%
if P.sensitivitymaps == true
    if strcmp(P.sensitvitymapscalc,'sense')==1|strcmp(P.sensitvitymapscalc,'sense2')==1
        P.senseLargeOutput=1;
        OutputSizeSensitivity=P.reconresolution; %what if data is not same length as this resolution??
        run FullRecon_SoS_sense.m;
        %             sens=MR_sense.Sensitivity; %??
        clear MR_sense;
    elseif strcmp(P.sensitvitymapscalc,'espirit')==1|strcmp(P.sensitvitymapscalc,'openadapt')
        run FullRecon_SoS_sense.m;
        
    elseif strcmp(P.sensitvitymapscalc,'ones')
        sens=ones([P.reconresolution,nc]); 
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

%% Remove oversampling in z-direction
zres=max(unique(MR.Parameter.Encoding.ZRes));    % 2017-01-23 pdh added
% max(unique()) because MR.Parameter.Encoding.ZRes contains an array
% instead of single value
slices_to_keep=[1+((ny-zres)/2):zres+((ny-zres)/2)];
slices_to_keep=floor(slices_to_keep);
kdatau=kdatau(:,:,slices_to_keep,:,:);


%% get first guess
disp('First guess')
for selectslice=P.reconslices       % sort the data into a time-series
    fprintf('%d - ',selectslice)
    tempy=squeeze(double(kdatau(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
    
    if ~P.GPU
        tempE=MCNUFFT(ku(:,:,:),sqrt(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
    else
        tempE=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));
    end
    
    R(:,:,selectslice,:)=(tempE'*tempy); %first guess
end
R(isnan(R))=0;

%% some parameters that are needed during recon/saving
P.DCEparams.lambda = double(0.25*max(abs(R(:))));  %regularization
P.voxelsize=MR.Parameter.Scan.AcqVoxelSize;
P.ku=ku;
P.wu=wu;

%% write big files to temporary folder
fprintf('\nWriting temporary files:')

cd(P.foldertemp)

for sl=P.reconslices
    fprintf('%i - ',sl)
    name=['temp_data_slice_',num2str(sl),'.mat'];
    Ksl=kdatau(:,:,sl,:,:);
    Rsl=R(:,:,sl,:);
    senssl=sens(:,:,sl,:);
    save(name,'Ksl','Rsl','senssl')
end
fprintf('\n Finished \n')


% save general options
cd(P.foldertemp)
nameP='temp_options_P.mat';
save(nameP,'P');

clear kdatau R sens;

%%  L1 minimization algorithm (NLCG)

for selectslice=P.reconslices;     %to do: CHANGE TO RELEVANT SLICES OMNLY
    
    % load relevant data
    cd(P.foldertemp)
    name=['temp_data_slice_',num2str(selectslice),'.mat'];
    vars=load(name)
    %     nameP='temp_options_P.mat';
    %     P=load(nameP)
    
    
    nc=size(vars.Ksl,4);
    k_weighted=squeeze(double(vars.Ksl)).*permute(repmat(sqrt(P.wu),[1 1 1 nc]),[1 2 4 3]);
    
    if ~P.GPU
        NufftOP=MCNUFFT(P.ku,P.wu,double(squeeze(vars.senssl)));
    else  % to do...
        NufftOP=GPUNUFFTT(P.ku,sqrt(P.wu),double(squeeze(vars.senssl)));
    end
    
    
    fprintf('\n GRASP reconstruction slice: %i of %i \n',selectslice,P.reconslices(end))
    
    res=double(squeeze(vars.Rsl));
    for outeriter=1:P.DCEparams.outeriter
        res=CSL1NlCg_experimental(res,P.DCEparams,k_weighted,NufftOP,selectslice);
    end
    recon_cs(:,:,selectslice,:) = res;
    
    
end

%% CLEAR CORR
if P.clearcorr
temp=1
clearmap=sum(abs(senssl),4).^1;
reconCLEAR1=bsxfun(@times,recon_cs(:,:,10,:),clearmap);
size(reconCLEAR1)
imshow(abs(reconCLEAR1(:,:,1,1)),[])
end
%%

description='description'
cd(P.resultsfolder)
nii=make_nii(squeeze(abs(flip((permute(recon_cs(:,:,:,:),[2 1 3 4]))))),P.voxelsize,[],[],description);
save_nii(nii,strcat(P.filename,'CS_N_FR','.nii'))



end
