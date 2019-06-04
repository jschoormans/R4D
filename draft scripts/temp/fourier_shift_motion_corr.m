% test of nonrigid motion correction (J Cheng) Idea
% Use stack of z-centers with fourier shift theorem

%%
clear gating_signal
for chan=1:params.nc;
for nz=1:params.nz;
gating_signal(nz,chan,:)=(ksp(params.cksp,:,nz,chan)); %not KSP2!!!
end
end

%% 
chan=1
figure(1);
subplot(311);imshow(squeeze(real(gating_signal(:,chan,:))),[]);
subplot(312);imshow(squeeze(imag(gating_signal(:,chan,:))),[]);
subplot(313);imshow(squeeze(abs(gating_signal(:,chan,:))),[]);

%%
% so real signal ~ sin(2pi*k*d)) and d ~ sin(2*pi*f_resp)
% ==> we want to find 2pi*k*d 
for nz=1:44;
nz
basesignal(nz,:)=squeeze(imag(gating_signal(nz,chan,:)))./squeeze(imag(gating_signal(nz,chan,1)));
% basesignal=basesignal./squeeze(real(gating_signal(25,chan,:)))
% basesignal=basesignal./smooth(basesignal,100);

basesignal(nz,:)=basesignal(nz,:)-mean(basesignal(nz,:));
basesignal(nz,:)=basesignal(nz,:)./max(abs(basesignal(nz,:)));
arcsin_gs(nz,:)=acos(basesignal(nz,:));

end

nz=1
figure(2); 
hold on; 
plot(basesignal(nz,:),'r')
plot(abs(arcsin_gs(nz,:)),'k')
hold off

figure(3); 
hold on; 
plot(mean(basesignal(:,:),1),'r')
plot(mean(abs(arcsin_gs(:,:)),1),'k')
hold off

%% PCA

% remove the mean variable-wise (row-wise)
data=arcsin_gs';
size(repmat(mean(data,1),[size(data,1) 1]))
data=data-repmat(mean(data,1),[size(data,1) 1]);

%scale by sigma
Vardata=std(data);
data=data./repmat(Vardata,[params.nspokes 1]);



if params.visualize==1;
figure(992); imshow(data,[]); end

% calculate eigenvectors (loadings) W, and eigenvalues of the covariance matrix
[W, EvalueMatrix] = eig(cov(data'));
Evalues = diag(EvalueMatrix);

% order by largest eigenvalue
Evalues = Evalues(end:-1:1);
W = W(:,end:-1:1); W=W';



if params.visualize==1;
figure(995); hold on ;
for ii=1:10;
    tvector=linspace(0,params.nspokes/params.Fs,params.nspokes);
    plot(tvector,(ii/4)+W(ii,:));
end
hold off
end
%% conjugate symmetry

figure(5)
ii=2
hold on
plot(squeeze(basesignal(25+ii,:)),'r')
plot(squeeze(basesignal(25-ii,:)),'k')

hold off

