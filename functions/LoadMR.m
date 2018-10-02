% LoadMR%reload MR object
if P.reloadMR==1
    if exist([P.filename,'_saveMRData.h5']); %saved MR object
        fprintf('Load MR Object\n')
        cd(P.resultsfolder);
%         load([P.filename,'_saveMR.mat'])
        MR.Data=h5read([P.filename,'_saveMRData.h5'],'/Data')
        
        P.isLoaded=1; 
    else
        P.isLoaded=0;
    end
else
    P.isLoaded=0; 
end