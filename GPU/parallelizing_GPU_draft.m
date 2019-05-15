% draft code for parallelizing GPU
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/GPU')
%load('femoral3DData.mat')
%% get first guess
tic
disp('First guess')
kdatau2=ifft(kdatau,[],3); 

for selectslice=P.reconslices       % sort the data into a time-series
    fprintf('%d - ',selectslice)
    y=squeeze(double(kdatau2(:,:,selectslice,:,:))).*permute(repmat(sqrt(wu(:,:,:)),[1 1 1 nc]),[1 2 4 3]);
    NUFFTOP=GPUNUFFTT(ku(:,:,:),(wu(:,:,:)),squeeze(sens(:,:,selectslice,:)));    
    R(:,:,selectslice,:)=(NUFFTOP'*y); %first guess
end
R(isnan(R))=0;
fprintf('\nFirst Guess...');toc

%parfor is slower on the GPU...

%% in 3D...

% works... add the z -dimension though....
% make this an operator and run the recon in 3D???

osf = 2; wg = 3; sw = 8;

tic
disp('First guess-3D')
nt=size(ku,3)
nslices=size(kdatau,3)
ImageDim=[size(sens,1),size(sens,2),size(sens,3)]

kdatau


for tt=1%:nt
%     y=single(bsxfun(@times,kdatau(:,:,:,:,tt),sqrt(wu(:,:,tt)))); size(y)
    y=kdatau2(:,:,:,:,tt).*repmat(sqrt(wu(:,:,tt)),[1 1 nslices 8]);
    y=reshape(y,[],size(y,4)); size(y)
    k_all=ku(:,:,tt); size(k_all)
    k_all=repmat(k_all(:),[1 nslices]); size(k_all)
    
    k=zeros(3,numel(k_all(:))); 
    k(1,:)=real(col(k_all));
    k(2,:)=imag(col(k_all));
    
    nz0=[MR.Parameter.Encoding.KzRange(1):MR.Parameter.Encoding.KzRange(2)]/abs(MR.Parameter.Encoding.KzRange(1)*2);
    nz0=nz0.'*ones([1,numel(wu(:,:,tt))]);
    k(3,:)=nz0(:);

    w_all=repmat(wu(:,:,tt),[1 1 nslices]); size(w_all)
    
    NUFFTOP=gpuNUFFT(k.',ones(size(w_all(:))),osf,wg,sw,ImageDim,sens,true);
    R2(:,:,:,tt)=(NUFFTOP'*y); %first guess

end

%3D gives all zeroes now...

R2(isnan(R2))=0;
fprintf('\nFirst Guess...');toc

%%
sl=25
figure(1); 
imshow(abs(R(:,:,sl,1)),[0 2e1])

%
figure(2); 
imshow(abs(R2(:,:,sl,1)),[])

%%
co=[1:size(k,2)];
figure(11);
plot3(k(1,co),k(2,co),k(3,co))

%%
NUFFTOP=GPUNUFFTT3D(k,w_all(:),osf,wg,sw,ImageDim,sens,true);
%%
figure(4)
plot3(k(1,:),k(2,:),w_all(:))


