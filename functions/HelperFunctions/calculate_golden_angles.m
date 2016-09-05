%GOLDEN ANGLES
format long;
tau=double(1+sqrt(5))/2;
for n=1:100;
psi(n)=(pi)/(tau+n-1);
end
TGangles=psi*(180/pi);


for n=1:100;
for j=3:20;
    Serie(n,1)=1;
    Serie(n,2)=n;
    Serie(n,j)=Serie(n,j-2)+Serie(n,j-1);
end
end