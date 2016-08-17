function [MR,P]=FullRecon_SoS_3D(P)
P=checkGAParams(P);
disp('TO DO: CONVERT TO BART-- THIS IS NOT GOOD')
MR=GoldenAngle_Recon(strcat(P.folder,P.file)); %initialize MR object
if P.sensitivitymaps == true
    run FullRecon_SoS_sense.m;
end
[MR,P] = UpdateReadParamsMR(MR,P);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MR.Perform;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end