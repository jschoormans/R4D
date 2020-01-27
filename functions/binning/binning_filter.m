%DESIGN FILTER
function output=binning_filter(mckspq,params)
input=mckspq;

cutofffreq=params.GAfreq;
Fs=params.Fs*params.oversampling;
Passband1=params.PCAfreqband(1);
Passband2=params.PCAfreqband(2);


switch params.filtertype
    case 'band-pass'
        disp('filtering the gating-signal with a band-pass filter')
        
        Hd = designfilt('bandpassfir', 'StopbandFrequency1',Passband1*0.7, 'PassbandFrequency1',Passband1, 'PassbandFrequency2',Passband2, 'StopbandFrequency2',Passband2*1.3, 'StopbandAttenuation1', 30, 'PassbandRipple', 1, 'StopbandAttenuation2', 40, 'SampleRate', Fs, 'DesignMethod', 'equiripple');
    case 'band-stop'
        disp('filtering the gating-signal with a band-stop filter')
        Hd = designfilt('bandstopiir','FilterOrder',20,'HalfPowerFrequency1',0.98*cutofffreq,'HalfPowerFrequency2',1.02*cutofffreq,'SampleRate',Fs);
%         Hd = designfilt('bandstopfir','FilterOrder',20,'CutoffFrequency1',0.95*cutofffreq,'CutoffFrequency2',1.05*cutofffreq,'SampleRate',Fs);
end
output=filtfilt(Hd,double(input));
end

%%PASSBANDFREQ1: VOOR 7 MAAKT HET NIET UIT 7/6/5/4