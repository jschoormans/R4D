function  res = TV2_Temp()

%res = TV2_Temp()
%
% Implements a difference operator along the time dimensin for dynamic MRI
% 2016 J SCHOORMANS
%improved adjoint operator: using cumsum;

res.adjoint = 0;
res = class(res,'TV2_Temp');

