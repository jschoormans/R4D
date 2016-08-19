
function [kdatau,ku,phaseval,indexphase] = sort_in_bins(gating_signal,ksp2,k,params)
switch params.sortingmethod
    case 'v' %value (VERY TEMP!)
        [kdatau,ku,phaseval,indexphase] = sort_in_bins_value(gating_signal,ksp2,k,params);
        
    case 'p' %phase
        [kdatau,ku,phaseval,indexphase] = sort_in_bins_phase(gating_signal,ksp2,k,params);
        
    case 'p2' %phase2
        [kdatau,ku,phaseval,indexphase] = sort_in_bins_phase2(gating_signal,ksp2,k,params);
        
    otherwise
        error('sortingmethod unknown!')
end



end