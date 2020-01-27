function [pks,locs,mins,minlocs] = peak_finding_gating_signal (gating_signal,params)

minpeakdistance=params.minpeakdistance*params.oversampling; %oversampling;

disp('Finding peaks and valleys of the gating_signal')
Prom=(max(gating_signal)-min(gating_signal))/30; %Peak prominence at least...
[pks,locs,w1,p1]=findpeaks(double(gating_signal),'MinPeakProminence',Prom,'MinPeakDistance',minpeakdistance); %DISTANCE: 1.5 S CORRESPONDS TO 21 SPOKES
[mins,minlocs,w2,p2]=findpeaks(-double(gating_signal),'MinPeakProminence',Prom,'MinPeakDistance',minpeakdistance);


if params.visualize==1
    figure(103)
    subplot(2,1,1)
    hold on
    plot(gating_signal,'b')
    plot(locs,pks,'r+')
    plot(minlocs,-mins,'g+')
    hold off
    title('peak finding result')
end


end