function [ksp_sorted,k_sorted,gating_signal,indexphase] = ksp2frames(ksp2,k,params,gating_signal)
%ksp2frames(ksp,k,sortvector,params) Sorts radial k-space spokes into frames
%JASPER SCHOORMANS - AMC AMSTERDAM - july 2016

%TO DO: -ADD DETAILED EXPLANATION
%       -ADD MORE FILTERING OPTIONS

%INPUT PARAMETERS

%ksp2:stack-of-stars radial k-space data. Format: (fe,spokes,z,channels): after a FT in the
%z-direction, assumption: measured in z-y order
%gating_signal: optional vector to be used for gating: needs to be the same
%length as the number of spokes

%params.gatingchans: channels to use in self-gating
%params.gatingmethod='ZIP' / 'PCA' / 'ICA_PCA' other sorting methods
%params.goldenangle : angle (in degrees) used for acquisition
%params.smoothingmethod: 'smooth';'none';'filter'
%params.filtertype='band-pass'/'low-pass'/'band-stop'
%params.smoothspan=5; %value for MA-filter
%params.visualize: 1=on; 0=off
%params.minpeakdistance=4 %minimum distance between peaks in the gating_signal
%params.sortingmethod='v'  %method of sorting the gating_singal: p=phase;
%v=value; p2; v2
%params.nBins=6;%number of bins in which to sort the k-space
%params.Fs: sampling frequency (Hz)
%params.plotZIP: 1 for test to see best ZIP channel
%params.PCAfreqband=[0.5 1] %frequency band in which you expect your gating
%signal (for PCA) (in Hz)
%params.
%params.PCAVar  :amount of variance to be explained by PCA before ICA (0-1) [0.7] 
%params.nICA    : number of indepent components to make [10]
% gatingnz
%gatingchans

%%% START CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOME PARAMETERS DECLARATION
params.nx=size(ksp2,1);
params.nspokes= size(ksp2,2);
params.nz=size(ksp2,3);
params.nc=size(ksp2,4);
params.cksp=round(1+params.nx/2);
params.oversampling=1;


% CHECK IF PARAMETERS DONT EXIST; GIVE THEM DEFAULT VALUE; 
if ~isfield(params,'gatingchans'); disp('no gating channels set: default all chans'); params.gatingchans=[1:params.nc]; end
if ~isfield(params,'gatingmethod'); params.gatingmethod='ZIP'; end
if ~isfield(params,'goldenangle'); error('specify the golden angle in params.goldenangle'); end
if ~isfield(params,'smoothingmethod'); params.smoothingmethod='none'; disp('Warning: no smoothing set'); end
if ~isfield(params,'smoothspan'); params.smoothspan=5; if strcmp(params.smoothingmethod,'smooth'); disp('Warning: no smoothspan set, default value 5'); end;end
if ~isfield(params,'visualize'); params.visualize=1; end
if ~isfield(params,'sortingmethod'); params.sortingmethod='v'; disp('Warning: no params.sortingmethod set; default: v'); end
if ~isfield(params,'minpeakdistance'); params.minpeakdistance=4'; if params.sortingmethod=='p'; if isfield(params,'PCAfreqband');params.minpeakdistance=params.Fs/params.PCAfreqband(2); disp('no minpekadistance set, calculated from PCAfreqband'); else ; disp('Warning: no minimum peak distance, default :4'); end; end;end
if ~isfield(params,'nBins'); params.nBins=6'; disp('Warning: no params.nBins, default:6');end
if ~isfield(params,'smoothingmethod'); if strcmp(params.smoothingmethod,'band-pass-filter');error('Set sampling frequency params.Fs'); end; end;
if ~isfield(params,'plotZIP'); params.plotZIP=0; end
if ~isfield(params,'PCAfreqband'); if strcmp(params.gatingmethod,'PCA')==1; error('specify frequency component params.PCAfreqband for PCA'); end; end
if ~isfield(params,'PCAfreqband'); if strcmp(params.gatingmethod,'PCA_ICA')==1; error('specify frequency component params.PCAfreqband for PCA_ICA'); end; end
if ~isfield(params,'PCAVar'); params.PCAVar=0.7; end; % if not given PCAVar=0.7
if ~isfield(params,'nICA'); params.nICA=10; end; % if not given nICA=10;
if ~isfield(params,'gatingchans'); params.gatingchans=[1:params.nc]; end; % if not given nICA=10;
if ~isfield(params,'gatingnz'); params.gatingnz=[1:params.nz]; end; % if not given nICA=10;


%1: SIGNAL TO USE FOR SORTING
if nargin==4;
    disp('The provided gating_signal is used')
    if length(gating_signal)~=params.nspokes;
        error('The length of the gating_signal is not equal to the number of spokes! Impossible.')
    end
elseif nargin==3
    %MAKE SIGNAL BASED ON KSP AND PARAMS
    disp('The gating_signal is calculated')
    [gating_signal] = generate_gating_signal(ksp2,params); %IF NO GATING SIGNAL PROVIDED; GENERATE
else
    error('number of input arguments not as expected')
end

%1A: CHECK IF SIGNAL IS REAL-VALUED AND DOUBLE
if ~isreal(gating_signal)
    gating_signal=abs(gating_signal);
    disp('gating_signal is complex-valued. Absolute value taken.')
end

%1B: OVERSAMPLE THE SIGNAL 10 TIMES
params.oversampling=10;
gating_signal_os= oversample_gating_signal(gating_signal,params);

%1C: SMOOTH/FILTER GATING SIGNAL
gating_signal_os_s= smooth_gating_signal(gating_signal_os,params);
gating_signal_s=gating_signal_os_s(1:params.oversampling:end);
if params.visualize==1;
    figure(101); subplot(211); hold on; plot(gating_signal_os); plot(gating_signal_os_s); hold off;    title('gating signal before/after smoothing')
end

%2. SORT THE gating_signal IN BINS

%2B: SORTING IN BINS
[ksp_sorted,k_sorted,phaseval,indexphase] = sort_in_bins(gating_signal_os_s,ksp2,k,params);


%2D: VISUALIZE
if params.visualize==1
    cmap=jet(params.nBins);
    figure(101);
    title('sorted into frames')
    subplot(212);hold on;
    plot(gating_signal_s)
    for i=1:params.nBins
        plot(indexphase(i,:),gating_signal_s(indexphase(i,:)),'MarkerFaceColor','none','MarkerEdgeColor',cmap(i,:),'Marker','*','Linestyle','none');end
    hold off
    colorbar('Ticks',linspace(0,1,params.nBins),'TickLabels',[1:1:params.nBins]); colormap(cmap)
    figure(102)
    for i=1:params.nBins
        subplot(ceil(params.nBins/2),3,i)
        plot(k_sorted(:,:,i))
    end
    
        %plot of frequency spectrum after filtering
    L=floor(length(gating_signal_s)/2);
    Fourier_signal=abs(fftshift(fft(gating_signal_s)));
    freqs=linspace(-0.5,0.5,length(gating_signal_s)).*params.Fs;
    figure(996);
    stem(freqs(L:end),Fourier_signal(L:end),'r');
    title('spectrum of filtered/smoothed gating signal');
    xlabel('frequency (Hz)');  ylabel('abs value of component')
    
    
    
    
    
    
    
end

disp('k-space succesfully sorted into frames!')
end

