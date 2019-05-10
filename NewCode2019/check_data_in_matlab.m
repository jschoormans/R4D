cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/NewCode2019')

R=readcfl('data/femdatacfl');

%%
setenv('TOOLBOX_PATH','/home/jschoormans/bart/bart-LAPACKE-bld')
bartJ('version')

R1=ifft(R,[],3);
R1=R1(306:405,1:250,29,1);
traj=bartJ('traj -r -G -s12 -x100 -y250');
size(R1)
recon=bartJ('nufft -i',traj,R1);
figure(1); imshow(abs(recon(:,:,1,1)),[]);
figure(2); imshow(abs(R1(:,:,1,1)),[]);

%%
R1=ones(100,2000); 
traj=bart('traj -r -G -x100 -y2000');
recon=bart('nufft -i',traj,R1);
figure(3); imshow(abs(recon(:,:)),[]);

