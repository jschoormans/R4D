function gating_signal_os= oversample_gating_signal(gating_signal,params)

%oversamples the gating signal 10 times;

x=[1:1:params.nspokes]; xq=[1:(1/params.oversampling):params.nspokes];lkspq=size(xq);
gating_signal_os=interp1(x,gating_signal,xq);

end