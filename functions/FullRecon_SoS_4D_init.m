function [MR,P,ku,kdatau,k]=FullRecon_SoS_4D_init(P)

P=checkGAParams(P);
MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
%PARAMETERS
[MR,P] = UpdateReadParamsMR(MR,P);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MR.Perform1;    %reading and sorting data
MR.CalculateAngles;
MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3); %eventually: remove slice oversampling
[nx,ntviews,ny,nc]=size(MR.Data);
goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);


%% do binning
TR=MR.Parameter.Scan.TR;
halfscan=MR.Parameter.Scan.HalfScanFactors(2);

P.binparams.Fs=(size(MR.Data,3)*halfscan*TR*1e-3)^(-1); %!!!
P.binparams.goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');

[kdatau,ku] = ksp2frames(MR.Data,k,P.binparams);
end
