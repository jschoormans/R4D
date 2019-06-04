% GPU BART QUICK TEST 
addpath('/scratch/jschoormans/')



% define radial trajectory 
traj=bart('traj -r -G');

% define radial phantom k-space
K=bartJ('phantom -s6 -t',traj);

% divide k-space in frames 
nsp=16
nfr=floor(128/nsp);
K2=zeros(1,128,nsp,6,nfr);
for t=1:nfr
    spokes=[1+(t-1)*nsp:(t)*nsp];
    K2(:,:,:,:,t)=K(:,:,spokes,:);
end
K2=permute(K2,[1 2 3 4 6 7 8 9 10 11 5]); 

% divide traj in frames
traj2=zeros(3,128,nsp,nfr);
for t=1:nfr
    spokes=[1+(t-1)*nsp:(t)*nsp];
    traj2(:,:,:,t)=traj(:,:,spokes);
end
traj2=permute(traj2,[1 2 3 5 6 7 8 9 10 11 4]); 


% define sensitivity maps 
S=bartJ('phantom -S6');

% pics recon 
tic
R=bartJ('pics -RT:1024:0:0.0 -C5 -G -i50 -S -t',traj2,K2,S);
timerecon=toc

figure(1)
montage(squeeze(abs(R)),'DisplayRange',[0 1e-1])