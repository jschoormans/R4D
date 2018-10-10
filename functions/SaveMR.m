% Save MR object to temp file 

% Save ksp to h5f file 


%% save MR object in mat file 
% removal of mat file should be done manually (find in resultsfolder) 

if P.saveMR==1
    if ~exist([P.filename,'_saveMRData.h5']); %saved MR object
        fprintf('\n !! Saving MR object !! \n')

        Data=single(MR.Data); 
        MR.Data=[]; clear MR.Data; 

%         tic
%         cd(P.resultsfolder);
%         save([P.filename,'_saveMR.mat'],'MR','-v7.3')
%         toc
        
        tic
        h5create([P.filename,'_saveMRData.h5'],'/Data',size(Data))
        h5write([P.filename,'_saveMRData.h5'],'/Data',single(Data))
        toc
    end
end
