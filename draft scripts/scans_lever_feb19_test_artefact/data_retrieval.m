addpath(genpath('/opt/amc/matlab/toolbox/MRecon'))
MRecon('version')


cd('/home/jschoormans/lood_storage/divi/Ima/parrec/jhrunge/Studies/DCErecon/Test_12FEB2019/2019_02_12/dc_35509/')

MR=GoldenAngle_Recon('dc_12022019_1854289_3_2_dce_liver_sos_3.5mmV4.raw')
MR.Perform1;                        %reading and sorting data
MR.CalculateAngles;
%MR.PhaseShift;
MR.Data=ifft(MR.Data,[],3);         %eventually: remove slice oversampling


MR.Data=ifft(MR.Data,[],3);

if true
% load noise data
MR2=MRecon('dc_12022019_1854289_3_2_dce_liver_sos_3.5mmV4.raw')
MR2.Parameter.Parameter2Read.typ=5
MR2.ReadData
MR2.PDACorrection
MR2.RandomPhaseCorrection
MR2.DcOffsetCorrection
MR2.MeasPhaseCorrection
MR2.SortData
end

% save files 
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/NewCode2019/matlab/scans_lever_feb19_test_artefact')

for ii=30
h5create(['data_all_coils_nocorr_r',num2str(ii),'.h5'],'/Data',size(MR.Data(:,:,ii,:)))
h5write(['data_all_coils_nocorr_r',num2str(ii),'.h5'],'/Data',real(MR.Data(:,:,ii,:)))


h5create(['data_all_coils_nocorr_im',num2str(ii),'.h5'],'/Data',size(MR.Data(:,:,ii,:)))
h5write(['data_all_coils_nocorr_im',num2str(ii),'.h5'],'/Data',imag(MR.Data(:,:,ii,:)))

end

if 0
h5create('noise_all_coils_r.h5','/Noise',size(MR2.Data))
h5write('noise_all_coils_r.h5','/Noise',real(MR2.Data))

h5create('noise_all_coils_im.h5','/Noise',size(MR2.Data))
h5write('noise_all_coils_im.h5','/Noise',imag(MR2.Data))


end






