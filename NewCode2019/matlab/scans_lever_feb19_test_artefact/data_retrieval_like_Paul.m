%preproc like Pauls script...
cd('/home/jschoormans/lood_storage/divi/Ima/parrec/jhrunge/Studies/DCErecon/Test_12FEB2019/2019_02_12/dc_35509/')

disp('Reading data...')
MR = MRecon('dc_12022019_1854289_3_2_dce_liver_sos_3.5mmV4.raw');

% reconstruct standard (imaging) data and noise data
MR.Parameter.Parameter2Read.typ = 1;
MR.Parameter.Parameter2Read.Update;

% switch off for performance reasons (after recon it is
% switched back to original state again)
AutoUpdateStatus = MR.Parameter.Recon.AutoUpdateInfoPars;
MR.Parameter.Recon.AutoUpdateInfoPars = 'no';

%     % set coil suppression parameters
%     MR.Parameter.Recon.ArrayCompression=P.ArrayCompression;
%     MR.Parameter.Recon.ACNrVirtualChannels=P.NrVirtualChannels;

% MR.Perform pipeline ------------------------------
MR.ReadData;
disp('Performing basic corrections...')
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;
disp('Sorting the data...')
MR.SortData;
data_ksp = MR.Data;

%% save files 
cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/NewCode2019/matlab/scans_lever_feb19_test_artefact')

for ii=[25,50]
h5create(['data_all_coilsP',num2str(ii),'.h5'],'/Data',size(MR.Data(:,:,ii,:)))
h5write(['data_all_coilsP',num2str(ii),'.h5'],'/Data',MR.Data(:,:,ii,:))
end
