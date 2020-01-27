function dataout= smooth_gating_signal(gating_signal,params)
% smooths the gating_signal as specified by params.smoothingmethod


 switch params.smoothingmethod
     case 'filter'
         % filters the golden angle rot frequency from the gating_signal
         params.GAfreq=params.Fs*(params.goldenangle/360); %freq of GA signal
         dataout=real(binning_filter(gating_signal,params));
         
     case 'smooth'
         disp('smoothing the gating-signal with a MA filter')
         dataout=smooth(gating_signal,params.smoothspan);

     case 'none'
         dataout=gating_signal;
     otherwise 
         error('params.smoothingmethod unknown/wrong')
 end
end



