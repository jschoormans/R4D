% PRINCIPAL COMPONENT ANALYSIS

function [gating_signal2,W] = ICA_gating_signal(ksp2,params)

% for chan=1:params.nc;
% gating_signal(chan,:)=sum(abs(ksp2(params.cksp,:,:,chan)),3);
% end
clear gating_signal

for chan=1:params.nc;
for nz=1:params.nz
gating_signal(nz,chan,1,:)=abs(ksp2(params.cksp,:,nz,chan));
gating_signal(nz,chan,2,:)=imag(ksp2(params.cksp,:,nz,chan));
gating_signal(nz,chan,3,:)=real(ksp2(params.cksp,:,nz,chan));
% gating_signal(nz,chan,4,:)=angle(real(ksp2(params.cksp,:,nz,chan))+1j*imag(ksp2(params.cksp,:,nz,chan)));
% gating_signal(nz,chan,5,:)=sum(abs(ksp2(:,:,nz,chan)).^2);

end
end

%reshape gating_signal
gating_signal=reshape(gating_signal,[size(gating_signal,1)*size(gating_signal,2)*size(gating_signal,3),params.nspokes]);


if params.visualize==1;
figure(992); imshow(gating_signal.',[]); title('input data for ICA'); xlabel('coil*slice dimension');ylabel('time (Fs)');end

nICA=3;
[W] = myICA(gating_signal,nICA);
figure(99);hold on ; for i=1:nICA;plot(W(i,:)'+3*i);end


% generate PCA component space (PCA scores)
% pc = W * data;


%find which PC has the most energy in a prescribed frequency band:
GAfreq=params.Fs*(params.goldenangle/360); %freq of GA signal
if GAfreq<params.PCAfreqband(1) %ok
elseif GAfreq>params.PCAfreqband(2) %ok
else; fprintf(2,'WARNING: params.PCAfreqband includes the goldenangle frequency!!! \n'); end

freqs=linspace(-0.5,0.5,length(W(1,:)))*params.Fs;
FW=abs(fftshift(fft(W,[],2),2));

bandfreqs= (freqs < params.PCAfreqband(2)).*(freqs > params.PCAfreqband(1));

EnergyIC=sum(FW(:,logical(bandfreqs)).^2,2);

[~,indexPC]=sort(EnergyIC,'descend');
PCA_choice=indexPC(1);

if isfield(params,'PCA_PCnr'); %if specified; use certain PC instead of the one with max energy (temporary option?)
    disp('PCA chosen bases on param.PCA_PCnr instead of max energy in specified frequency band!')
    gating_signal2=double(W(params.PCA_PCnr,:));
    PCA_choice=params.PCA_PCnr;
end


if params.visualize==1;
    
    figure(995); hold on ;
    for ii=1:nICA;
        tvector=linspace(0,params.nspokes/params.Fs,params.nspokes);
        plot(tvector,(ii*4)+W(ii,:));
        text(tvector(5),(ii*4-(2)),['Principal component ',num2str(ii),', Energy in f-band :' ,num2str(EnergyIC(ii))])
        if ii==PCA_choice;
           text(tvector(end),4*ii,'chosen PC') 
        end
    end
    title('PCA analysis: first 10 independent components')
    xlabel('time (s)')
    ylabel('')
    hold off

    %%%%%
    
    
    [~, GAfreqindex]=sort(abs(freqs-GAfreq),'ascend');
    figure(993);
    hold on 
    L=floor(length(FW)/2);
    stem(freqs(L:end),FW(PCA_choice,L:end),'r');
    stem(freqs(logical(bandfreqs)),FW(PCA_choice,logical(bandfreqs)),'b');
    text(freqs(GAfreqindex(1)),double(FW(PCA_choice,GAfreqindex(1))),'*Golden Angle Frequency')
    hold off
    title('spectrum of chosen independent component');
    xlabel('frequency (Hz)');  ylabel('abs value of component')
end

gating_signal2=double(W(PCA_choice,:));


end