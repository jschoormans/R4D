function [nspokes]=check_golden_angle(goldenangle,nspokes,MR)

calculate_golden_angles;
ngoldenangle=find(single(TGangles)==single(goldenangle));
if isempty(ngoldenangle)
    nspokes=nspokes;
    disp(['goldenangle :',num2str(goldenangle),'not a known golden angle']);
else
    if sum(nspokes==Serie(ngoldenangle,:))==0
        disp('The number of spokes has been changed for good k-space coverage!')
        nspokes=min(Serie(ngoldenangle,(Serie(ngoldenangle,:)>nspokes)))
    else
        nspokes=nspokes;
    end
end
end