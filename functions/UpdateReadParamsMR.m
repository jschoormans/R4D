function [MR,P] = UpdateReadParamsMR(MR,P)


if isfield(P,'channelstoread')
MR.Parameter.Parameter2Read.chan=P.channelstoread;
end
if isfield(P,'spokestoread')
MR.Parameter.Parameter2Read.ky=[0:P.spokestoread]';
end

if P.channelcompression ==true;
    fprintf('Using channel compression to %d channels',P.cc_nrofchans);
    MR.Parameter.Recon.ArrayCompression='Yes';
    MR.Parameter.Recon.ACNrVirtualChannels=P.cc_nrofchans;
end

if P.oneTEtemp ==true;
    MR.Parameter.Parameter2Read.echo=[0]
end

if isfield(P,'reconresolution');
    if ~strcmp(P.recontype,'3D');
    MR.Parameter.Encoding.XReconRes=P.reconresolution(1);
    MR.Parameter.Encoding.YReconRes=P.reconresolution(2);
    MR.Parameter.Encoding.ZReconRes=P.reconresolution(3);
    else 
        disp('P.reconresolution not yet supported with 3D recon!')
    end
end

MR.Parameter.Parameter2Read.Update; 


end