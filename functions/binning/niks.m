
cd('/home/jschoormans/lood_storage/divi/Temp/jasper/25august2016/raw_data/Results')
%%
close all
P.binparams.goldenangle=27.198409725000651
P.binparams.PCAfreqband=[0.4 0.8]
P.binparams.gatingmethod='PCA_test'
P.binparams.gatingmethod='PCA_ICA_test'
P.binparams.visualize=1;
P.binparams.PCAVar=0.7

P.binparams.nx=size(ksp2,1);
P.binparams.nspokes= size(ksp2,2);
P.binparams.nz=size(ksp2,3);
P.binparams.nc=size(ksp2,4);
P.binparams.cksp=round(1+P.binparams.nx/2);
P.binparams.oversampling=1;
P.binparams.dummy=1
P.binparams.dummyICA=1

% ksp2frames(ksp2,k,P.binparams);
    [gating_signal] = generate_gating_signal(ksp2,P.binparams); %IF NO GATING SIGNAL PROVIDED; GENERATE
