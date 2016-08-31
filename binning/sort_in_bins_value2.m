function [kdatau,ku,phaseval,indexphase] = sort_in_bins_value2(gating_signal,ksp2,k,params)
        disp('Sorting the gating_signal based on value and phase (derivative)')
        %maybe its best to smooth only for peak finding, and not for the
        %values???
        
        
        
        [pks,locs,mins,minlocs] = peak_finding_gating_signal(gating_signal,params);
        
        nspokesbin=floor(params.nspokes/params.nBins);
        phaseval=nan(1,length(gating_signal));
        
        
        %II: FIND DERIVATIVE AND ASSIGN PHASE
        gating_signal_smoothed=smooth_gating_signal(gating_signal,params); %do some extra smoothing
        phaseval=gradient(gating_signal_smoothed);
        phaseval=(phaseval>0)-(phaseval<0);

        phaseval=phaseval(1:params.oversampling:end); %remove oversampling
        gating_signal_pos=gating_signal(1:params.oversampling:end)+1-min(gating_signal(:));     %should all be positive values, remove oversampling
        [~,indexup]=sort(gating_signal_pos.*phaseval);
        II=[1:nspokesbin:nspokesbin*params.nBins+1];
        binsize=nspokesbin;
                
        kdatau=zeros(size(ksp2,1),binsize,size(ksp2,3),size(ksp2,4),params.nBins);
        ku=zeros(size(ksp2,1),binsize,params.nBins);
        phaseval=zeros(params.nBins,length(gating_signal));
        indexphase=zeros(params.nBins,binsize);
        
        for ii=1:params.nBins % sort the data into a time-series (maybe remove loop at later stage)
            kdatau(:,:,:,:,ii)=squeeze(ksp2(:,(indexup(II(ii):II(ii+1)-1)),:,:)); %kdatau now (nfe nspoke nslice nc nt) for each phase
            ku(:,:,ii)=squeeze(double(k(:,indexup(II(ii):II(ii+1)-1)))); %k-space coverage for each phase
            phaseval(ii,(indexup(II(ii):II(ii+1)-1)))=ii; %values for each phase
            indexphase(ii,:)=(indexup(II(ii):II(ii+1)-1));%indices for each phase
        end
end