addpath(genpath('/home/jschoormans/lood_storage/divi/Temp/barunderkamp/Scan_data/MSK_Lund_vNSA'))
folder=('/home/jschoormans/lood_storage/divi/Temp/barunderkamp/Scan_data/MSK_Lund_vNSA/subject_6_FFE_vNSA_succeeded/')
cd(folder)
files=dir('*.raw')

%%
for iter=[1:2]
    MR=MRecon(strcat(folder,files(iter).name));
    MR.Perform
    
    nii=make_nii(abs(MR.Data))
    filename=['Results/',files(iter).name(1:end-4),'_PERFORM.nii']
    cd(folder)
    save_nii(nii,filename)
    
end
