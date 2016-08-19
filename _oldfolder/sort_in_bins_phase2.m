function [kdatau,ku,phaseval,indexphase] = sort_in_bins_phase2(gating_signal,ksp2,k,params)

disp('Sorting the gating_signal based on phase2 - up and down')
[~,locs,~,minlocs] = peak_finding_gating_signal(gating_signal,params);

nspokesbin=floor(params.nspokes/params.nBins);
phaseval=nan(1,length(gating_signal));

epsilon=1e-5; %small random value;
for i=2:length(locs); %for all peaks
    lastmin=max(minlocs(minlocs<locs(i))); %last minimum
    lengthphase=locs(i)-lastmin;
    phases=(linspace(0,1-epsilon,lengthphase));
    phaseval(1,lastmin:locs(i)-1)=phases;
    
    nextmin=min(minlocs(minlocs>locs(i))); %last minimum
    lengthphase2=nextmin-locs(i);
    phases=(linspace(1,2,lengthphase2));
    phaseval(1,locs(i):nextmin-1)=phases;
end

phaseval_res=phaseval(1:params.oversampling:end); %RESAMPLED PHASE VALS
                        %REMOVE NANS...
                        [~,indexup]=sort(phaseval_res);

[~,indexnan]=find(isnan(phaseval_res));
[~,indexmembers]=ismember(indexnan,indexup);%
indexup(indexmembers)=[];

nspokesbin=floor(length(indexup)/params.nBins);
II=[1:nspokesbin:nspokesbin*params.nBins+1];
binsize=nspokesbin;


%%%%%%%%%%%%%%%%

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