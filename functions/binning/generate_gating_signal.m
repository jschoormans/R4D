function [gating_signal] = generate_gating_signal(ksp2,params)

if ~isfield(params,'gatingchans'); params.gatingchans=[1:size(ksp2,4)]; end;
if ~isfield(params,'gatingnz'); params.gatingnz=[1:size(ksp2,3)]; end;


switch params.gatingmethod
    case 'ZIP';
        disp('calculating the z-intensity projection.');
        gating_signal = generate_ZIP(ksp2,params);
    case 'cksp'
        disp('calculating the real-valued center of kspace.');
        gating_signal = generate_cksp_signal(ksp2,params);
    case 'PCA'
        disp('Principal Component analysis on real+imag+abs center of kspace');
        gating_signal = PCA_gating_signal(ksp2,params);
    case 'ICA'
        disp('Independent Component analysis on real+imag+abs center of kspace');
        gating_signal = ICA_gating_signal(ksp2,params);
    case 'PCA_ICA'
        disp('First: PCA, then Independent Component analysis on real+imag+abs center of kspace');
        gating_signal = PCA_ICA_gating_signal(ksp2,params);
    case 'PCA_test' %TESTING PURPOSES ONLY
        disp('Principal Component analysis on real+imag+abs center of kspace');
        gating_signal = PCA_gating_signal_test(ksp2,params);
    case 'PCA_ICA_test'
        disp('First: PCA, then Independent Component analysis on real+imag+abs center of kspace');
        gating_signal = PCA_ICA_gating_signal_test(ksp2,params);

end

end

