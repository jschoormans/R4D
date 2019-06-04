% draft


img_sens_sos = sqrt(sum(abs(sens).^2,4));
sens_normalized = sens./repmat(img_sens_sos,[1,1,1,8]);
y=ones(size(kdatau));



% cc=create_checkerboard(size(kdatau,3));
% y=bsxfun(@times,y,permute(cc,[1 3 2])); 


y=reshape(y,[],nc,nt);  % THIS SHOULD BE MOVED TO THE OPERATOR
size(y)
y=bsxfun(@times,y,sqrt(permute(w_all_t,[1 3 2]))); 
yt=y; 

NUFFTOP=GPUNUFFTT3D(k_all_t,sqrt(w_all_t),sens_normalized);

tic
R2=(NUFFTOP'*yt); %first guess
toc

Extdx=NUFFTOP*gather(R2);
toc

figure(1);clf; hold on; plot(abs(Extdx(1:1000,1,1)),'r'); plot(abs(y(1:1000,1,1)),'k'); hold off



