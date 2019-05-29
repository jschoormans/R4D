% find folder structure triple AA study
% run recon
% save in folders
folder='/home/jschoormans/lood_storage/divi/Projects/aaa/MRI/raw/dicom/'
l1=dir(folder) %layer 1

for study_n=1:25
    for session_n=1:2
        scan=['B',num2str(study_n,'%1.2d'),'_0',num2str(session_n)];
        pathh=[folder,scan,filesep,'GtpacknGo'];
        l=dir(pathh);

        scan
        while size(l,1)==3
            fprintf('into next subfolder... \n')
            fprintf(l(3).name)
            fprintf('\n')
            pathh=[pathh,filesep,l(3).name];
            l=dir(pathh);
        end
        
        try
            % find relevant file here...
            pat='3d_dce_tr.*raw';
            T=~cellfun('isempty',regexp({l.name},pat));
            disp(l(T).name)
            
            
        catch
            disp('error')
        end
        fprintf('\n\n\n')
        

    end
    
end    % if date folder exists --> go in there and go into next folder

cd('/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/R4D/General_Code/Studies/AAA')
save('filelocations.mat','F')

%%


