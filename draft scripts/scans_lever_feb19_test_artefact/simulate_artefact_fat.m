I=phantom()
I2=zeros(size(I))
I2(44:50,44:50)=3;

theta=1:2:180
R=zeros(367,90)
for ii=1:90
translatevector=5*[cos(2*pi*theta(ii)/360),sin(2*pi*theta(ii)/360)];
Itrans=imtranslate(I2,translatevector);
R(:,ii)=radon(Itrans+I,theta(ii));
end

Recon=iradon(R,theta)


figure(1); 
subplot(221)
imshow(I+I2,[])
title('object')

subplot(222)
imshow(R,[])
title('radon transform (=iFT of rad ksp)')

subplot(223)
imshow(abs(Recon),[])
title('inverse Radon recon')
