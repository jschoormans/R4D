
addpath(genpath('/opt/amc/matlab/toolbox/MRecon/'))

cd('/home/jschoormans/lood_storage/divi/Ima/parrec/jhrunge/Studies/DCErecon/Test_12FEB2019/2019_02_12/dc_35509/')
file='dc_12022019_1854289_3_2_dce_liver_sos_3.5mmV4.raw'

MR=MRecon(file)
%%
MR.Perform
