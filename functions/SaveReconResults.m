function [MR,P] = SaveReconResults(MR,P);


fprintf('filename=%s...\n',P.filename)
fprintf('Saving parameters to text file...\n');
% print parameter to text file



diary(P.filename)
diary on 
P
P.CS
P.espiritoptions
P.reconslices
fprintf('Golden-angle Stack-of-Stars Finished!\n')
diary off
end