
function [gating_signal] = generate_ZIP(ksp2,params)

disp('TO DO: check which one is the good ZIP!')
for i=1:params.nz
ZIPf(:,i)=sum(sum(i*(abs(ksp2(params.cksp,:,i,params.gatingchans))),4),1); %  ZIP: WEIGHTED CENTER : SUM OF ABS SIGNAL OF CENTER
end
gating_signal=sum(ZIPf,2);
gating_signal=gating_signal-mean(gating_signal);


if params.plotZIP==1
   %TEST TO SEE WHICH ZIP CHANNEL IS THE BEST
for chan=1:params.nc
   for i=1:params.nz
    ZIPt(:,i)=sum(sum(i*(abs(ksp2(params.cksp,:,i,chan))),4),1); %  ZIP: WEIGHTED CENTER : SUM OF ABS SIGNAL OF CENTER
   end
   ZIPftest(chan,:)=sum(ZIPt,2)/sum(ZIPt(:));
   ZIPftest(chan,:)=ZIPftest(chan,:)./max(ZIPftest(chan,:));


   figure(105); 
   hold on
   plot(abs(ZIPftest(:,1:500)),[])
   hold off
end
end

end