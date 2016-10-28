function res = mtimes(a,b)

if a.adjoint
    res = adjDz(b);
else
    res = b(:,:,[2:end,end]) - 2.*b + b(:,:,[1,1:end-1]);   %f(x+1)-f(x)
%     res = circshift(b(:,:,[1:end,end]),1,3) - 2*b + circshift(b(:,:,[1:end,end]),-1,3);   %f(x+1)-2f(x)+f(x-1)
end

function y = adjDz(x)
%  y=cumsum(x(:,:,[1,1:end-1]),3);
   y = x(:,:,[2:end,end]) - 2.*x + x(:,:,[1,1:end-1]);   %f(x+1)-f(x)
