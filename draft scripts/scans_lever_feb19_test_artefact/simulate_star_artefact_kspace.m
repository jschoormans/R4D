% simulate 'star' in gridded k-space: effet on image; 



traj = bart('traj -G -r -x256 -y512') ;
K=bart('phantom -k -t',traj);
size(K)


figure(1)
imshow(abs(squeeze(K)),[])

% add signal 
K(1,1:64,:)=K(1,1:64,:)+0.001
;
figure(1)
imshow(abs(squeeze(K)),[0 0.001])
title( 'k-space wth signal added')

imgrid=bart('nufft -i',traj,K);
kspgrid=bart('fft 7',imgrid);

figure(2);
subplot(121)
title('gridded ksp');
imshow(abs(squeeze(kspgrid)),[0 1])
subplot(122)
title('gridded image');
imshow(abs(squeeze(imgrid)),[0 0.01])


%% PART II
% only add signal to k-lines in one quarter of angles


traj = bart('traj -G -r -x256 -y512') ;
K=bart('phantom -k -t',traj);
size(K)
GAngle=(111.24/360)*2*pi
angles=mod([0:1:511]*GAngle,2*pi)

figure(1)
imshow(abs(squeeze(K)),[])

% add signal 
for ii=1:512
    if angles(ii)<(pi/2)
        K(1,1:128,ii)=K(1,1:128,ii)+0.002;
    end
end
;
figure(1)
imshow(abs(squeeze(K)),[0 0.001])
title( 'k-space wth signal added')

imgrid=bart('nufft -i',traj,K);
kspgrid=bart('fft 7',imgrid);

figure(2);
subplot(121)
title('gridded ksp');
imshow(abs(squeeze(kspgrid)),[0 1])
subplot(122)
title('gridded image');
imshow(abs(squeeze(imgrid)),[0 0.01])






