function [MR,P] = SaveReconResults(MR,P);


fprintf('filename=%s...\n',P.filename)
fprintf('Saving parameters to text file...\n');
% print parameter to text file



diary([P.filename,'.txt'])
diary on 
P
if isfield(P,'DCEparams')
    disp('DCE options:')
    P.DCEparams
end
if isfield(P,'CS')
    disp('CS options:')
    P.CS
end
if isfield(P,'espiritoptions')
    disp('espirit options:')
P.espiritoptions
end

if isfield(P,'spokestoread')
fprintf('first spoke %d, last spoke: %d',P.spokestoread(1),P.spokestoread(end))
else
    fprintf('all spokes used\n')
end
    fprintf('Golden-angle Stack-of-Stars Finished!\n')
diary off
end