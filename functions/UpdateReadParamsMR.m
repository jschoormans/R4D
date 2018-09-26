function [MR,P] = UpdateReadParamsMR(MR,P)


%% CHECK GOLDEN ANGLE
if ~isfield(P,'goldenangle')
    try 
        P.goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
    catch
        P.goldenangle=MR.Parameter.GetValue('`CSC_golden_angle');
    end
end

if isfield(P,'channelstoread')
disp('Selecting channels to read')
    MR.Parameter.Parameter2Read.chan=P.channelstoread;
end
if isfield(P,'spokestoread')
MR.Parameter.Parameter2Read.ky=P.spokestoread;
end

if P.channelcompression ==true;
    fprintf('Using channel compression to %d channels',P.cc_nrofchans);
    MR.Parameter.Recon.ArrayCompression='Yes';
    MR.Parameter.Recon.ACNrVirtualChannels=P.cc_nrofchans;
end


if ~isfield(P,'reconresolution') %TO TEST!!!
P.reconresolution(1)=round(MR.Parameter.Scan.FOV(1)./MR.Parameter.Scan.AcqVoxelSize(1));
P.reconresolution(2)=round(MR.Parameter.Scan.FOV(1)./MR.Parameter.Scan.AcqVoxelSize(1));
P.reconresolution(3)=round(MR.Parameter.Scan.FOV(2)./MR.Parameter.Scan.AcqVoxelSize(3));
end

% if isfield(P,'reconresolution'); %not sure about this
%     MR.Parameter.Encoding.XReconRes=P.reconresolution(1);
%     MR.Parameter.Encoding.YReconRes=P.reconresolution(2);
%     MR.Parameter.Encoding.ZReconRes=P.reconresolution(3);
% end

if isfield(P,'reconslices'); %check if reconslices are given
    if max(P.reconslices)>floor(max(unique(MR.Parameter.Encoding.ZRes)))
    error('there are not so many slices')
    end
else %given recon slices (mind oversampling!)
    P.reconslices=[1:floor(max(unique(MR.Parameter.Encoding.ZRes)))];
end


if  length(MR.Parameter.Parameter2Read.echo)>1
    disp('data has multiple echoes!')
    if strcmp(P.recontype,'4D')
        P.oneTEtemp =true;
        disp('only first echo used for 4D recon. If you want to reconstruct all echoes, use 5D recon!')
    end
    
end

if P.oneTEtemp ==true;
    MR.Parameter.Parameter2Read.echo=0;
else
    if strcmp(P.recontype,'4D')==true; %automatically use ONLY first echo for 4D recon;
            MR.Parameter.Parameter2Read.echo=0;
    end
end

if strcmp(P.recontype,'DCE')
    P.DCEparams.nspokes=check_golden_angle(P.goldenangle,P.DCEparams.nspokes);
    P.DCEparams.TimeResolution=P.DCEparams.nspokes*MR.Parameter.Labels.ScanDuration/MR.Parameter.Labels.Samples(2); %recalculate time resolution
 end
   



MR.Parameter.Parameter2Read.Update; 
end