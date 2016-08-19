function [gating_signal] = generate_cksp_signal(ksp2,params)

gating_signal=sum(real(ksp2(params.cksp,:,round(params.nz/3):round(2*params.nz/3),params.gatingchans)),3);


if params.plotZIP==1
   %TEST TO SEE WHICH CHANNEL IS THE BEST
for chan=1:params.nc
   gating_signal_test(:,chan)=sum(sum(real(ksp2(params.cksp,:,round(params.nz/3):round(2*params.nz/3),chan)),3),4);
end
figure(105);
imshow(abs(gating_signal_test(1:200,:)),[])

end

end