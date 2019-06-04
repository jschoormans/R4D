% VIRTUAL COILS 

% 3D SoS MRECON Object

clear all; close all; clc; 
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D')

folder='/home/jschoormans/lood_storage/divi/Projects/cosart/Abdomen/4-12-2015/'
% coil_survey='te_04122015_1056465_1000_5_wipcoilsurveyscanV4.raw'
% sense_ref='te_04122015_1057130_1000_8_wipsenserefscanclearV4.raw'
% file='te_04122015_1105551_7_2_wipatr11117st06hfclearV4.raw'
file='te_04122015_1115270_9_2_wipatr11117st08hfclearV4.raw'
% file='te_04122015_1127209_13_2_wipatr11112st06hfclearV4.raw'
% file='te_04122015


MR=GoldenAngle_Recon(strcat(folder,file));
MR.Parameter.Parameter2Read.ky=[0:1:50]'; %not necessary to load all data; 
MR.Parameter.Gridder.OutputMatrixSize=[100 100 84]
MR.Parameter.Encoding.XReconRes=100
MR.Parameter.Encoding.YReconRes=100

MR.Parameter.Scan.RecVoxelSize=[3.5 3.5 7]

MR.Perform1;
MR.CalculateAngles;
MR.PhaseShift;

MR.PerformGrid
size(MR.Data)
% MR.Perform2
MR.K2I;
size(MR.Data)
Raw=MR.Data;
MR.CombineCoils
SoS=MR.Data;

figure(1)
as(MR.Data)


%%
w=ones(1,size(Raw,4))   %virtual coil weightings
VC=zeros(size(SoS));
VC(31:50,11:50,15:30)=ones(20,40,16);
VCIm=VC.*SoS;
as(VCIm)

%% Virtual Coil Optimalization

x=size(Raw,1);y=size(Raw,2);z=size(Raw,3);nc=size(Raw,4)

RawR=reshape(Raw,[x*y*z,nc]);
VCR=reshape(VC,[x*y*z,1]);
SoSR=reshape(SoS,[x*y*z,1]);

% w=(inv(RawR.'*RawR))*RawR.'*((VCR).*SoSR)
w=pinv(RawR)*(reshape(VCIm,[x*y*z,1]))
%% CHECK WEIGHTS

RawWR=RawR*w;
RawW=reshape(RawWR,[x,y,z]);
as(RawW)

%%

MR2=GoldenAngle_Recon(strcat(folder,file));
MR2.Parameter.Parameter2Read.ky=[0:1:200]'; %not necessary to load all data; 
MR2.Perform1;
Ksp=MR2.Data;
MR2.PerformGrid
MR2.Perform2
MR2D=MR2.Data;

x=size(MR2D,1);y=size(MR2D,2);z=size(MR2D,3);nc=size(MR2D,4)
MR2DR=reshape(MR2D,[x*y*z,nc]);
%%
MR2DRW=MR2DR*w;
MR2DRW=reshape(MR2DRW,[x,y,z]);
as(MR2DRW)

%%

goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
Npe=size(Ksp,2)
RadialAngles=[0:(goldenangle)*(pi/180):(Npe-1)*(goldenangle)*(pi/180)]'; %relative angles measured (first set at 0)

KspCorr=phaseshift(Ksp,RadialAngles'); %phase correction

%%
xx=[1:201]
Xc=301;
Zc=42;42

figure(1);
hold on
plot(xx,abs(w.'*squeeze(Ksp(Xc,:,Zc,:)).'),'r')
plot(xx,abs(squeeze(Ksp(Xc,:,Zc,5))),'r--')
plot(xx,abs(squeeze(KspCorr(Xc,:,Zc,5))),'g--')
plot(xx,abs(w.'*squeeze(KspCorr(Xc,:,Zc,:)).'),'g')


plot(xx,1000*sin(2*pi*xx*goldenangle/360),'k--')
hold off

%%
figure(2)
hold on
scatter(mod(RadialAngles,2*pi),abs(w.'*squeeze(Ksp(Xc,:,Zc,:)).'),'r')
scatter(mod(RadialAngles,2*pi),abs(squeeze(Ksp(Xc,:,Zc,5))),'y')
scatter(mod(RadialAngles,2*pi),abs(squeeze(KspCorr(Xc,:,Zc,5))),'b+')
scatter(mod(RadialAngles,2*pi),abs(w.'*squeeze(KspCorr(Xc,:,Zc,:)).'),'g')
hold off

%% for the corrected weighted signal, calculate angle-dependent offset

RVC=abs(w.'*squeeze(KspCorr(Xc,:,Zc,:)).');
R=abs(squeeze(KspCorr(Xc,:,Zc,5)))

S=[ones(size(RadialAngles)) cos(mod(RadialAngles,2*pi)) sin(mod(RadialAngles,2*pi)) cos(mod(RadialAngles,2*pi)).^2 sin(mod(RadialAngles,2*pi)).^2 sin(mod(RadialAngles,2*pi)).*cos(mod(RadialAngles,2*pi))]
O=pinv(S)*RVC.' 

figure(3)
hold on
scatter(mod(RadialAngles,2*pi),RVC.','g')
plot(mod(RadialAngles,2*pi),O.'*S.','.')
hold off

%%
RVCC=RVC-O.'*S.'; %corrected data;
RC=R-(pinv(S)*R.').'*S.'; %corrected data;
figure(4)
hold on
plot(RVCC,'k')
plot(4000+RC,'r')
hold off
title('virtual coil (black) and one coil (red)')


