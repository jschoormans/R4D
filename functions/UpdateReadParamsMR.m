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


if isfield(P,'reconresolution');
    if ~strcmp(P.recontype,'3D');
    MR.Parameter.Encoding.XReconRes=P.reconresolution(1);
    MR.Parameter.Encoding.YReconRes=P.reconresolution(2);
    MR.Parameter.Encoding.ZReconRes=P.reconresolution(3);
    else 
        disp('P.reconresolution not yet supported with 3D recon!')
    end
end

if isfield(P,'reconslices'); %check if reconslices are given
    if max(P.reconslices)>round(MR.Parameter.Encoding.ZRes.*MR.Parameter.Encoding.KzOversampling)
    error('there are not so many slices')
    end
else %given recon slices (mind oversampling!)
    zdim=MR.Parameter.Encoding.ZRes(1).*MR.Parameter.Encoding.KzOversampling(1);
    os_slices=round(zdim-MR.Parameter.Encoding.ZRes(1));
    P.reconslices=[1+floor(os_slices/2):floor(os_slices/2)+MR.Parameter.Encoding.ZRes] 
end


if  size(MR.Parameter.Parameter2Read.echo)>1
    disp('data has multiple echoes!')
    if strcmp(P.recontype,'4D')
        P.oneTEtemp =true;
        disp('only first echo used for 4D recon. If you want to reconstruct all echoes, use 5D recon!')
    end
end

if P.oneTEtemp ==true;
    MR.Parameter.Parameter2Read.echo=[0]
else
    if strcmp(P.recontype,'4D')==true; %automatically use ONLY first echo for 4D recon;
            MR.Parameter.Parameter2Read.echo=[0]
    end
end


MR.Parameter.Parameter2Read.Update; 
end