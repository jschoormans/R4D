function w=Calc_VC_Weights(Raw,SoS,VC);
%function to calculate weights of virtual coils inputs: Raw: uncombined
%image; SoS: Sum-of-squares combined image

w=ones(1,size(Raw,4))   %virtual coil weightings

%% MAKE SOME GUI THAT ADDAS ONES TO RELEVANT PARTS OF VC MATRIX


%%
VCIm=VC.*SoS;
%% Virtual Coil Optimalization

x=size(Raw,1);y=size(Raw,2);z=size(Raw,3);nc=size(Raw,4)

RawR=reshape(Raw,[x*y*z,nc]);
VCR=reshape(VC,[x*y*z,1]);
SoSR=reshape(SoS,[x*y*z,1]);

% w=(inv(RawR.'*RawR))*RawR.'*((VCR).*SoSR)
w=pinv(RawR)*(reshape(VCIm,[x*y*z,1]))

end