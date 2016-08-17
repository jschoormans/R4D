%% EXAMPLE SCRIPT FOR A 3D RECONSTRUCTION

clear all; close all; clc;
addpath(genpath('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code'));
P=struct
%% PARAMETERS

P.binparams.visualize =1;
P.spokestoread=12;
%% FULL RECONSTRUCTION
%DEFINE PARAMS HERE
%[MR,P]=GOLDENANGLE(P)

%% RECONSTRUCTION IN STEPS

P=checkGAParams(P);
MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
[MR,P] = UpdateReadParamsMR(MR,P);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MR.Perform1;    %reading and sorting data
MR.CalculateAngles;
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3); %eventually: remove slice oversampling
[nx,ntviews,ny,nc]=size(MR.Data);
goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);

%% 3D BART WITH DCF

res=MR.Parameter.Encoding.XRes;
coordsfull=RadTraj2BartCoords(k,res);

wu=getRadWeightsGA(k);
wu=permute(wu,[3 1 2]);
% wu=ones(size(wu));

%write away weights matrix
weight_name = [P.resultsfolder '/weight'];
writecfl(weight_name, wu);


kdata=double(MR.Data(:,:,24,:));
kdata=permute(kdata,[3 1 2 4]);

bart_cmd = sprintf('pics -l2 -S -d5 -i2 -p %s -t', weight_name);

recon = bart(bart_cmd, coordsfull, kdata, ones(res,res,1,nc));
% recon=bart('rss 8',recon);

figure(1); imshow(squeeze(abs(recon)),[])
