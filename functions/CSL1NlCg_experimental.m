function [x,cost] = CSL1NlCg_experimental(x0,param,tempy,tempE,tempslice)
% 
% res = CSL1NlCg(param)
%
% Compressed sensing reconstruction of undersampled k-space MRI data
%
% L1-norm minimization using non linear conjugate gradient iterations
% 
% Given the acquisition model y = E*x, and the sparsifying transform W, 
% the pogram finds the x that minimizes the following objective function:
%
% f(x) = ||E*x - y||^2 + lambda * ||W*x||_1 
%
% Based on the paper: Sparse MRI: The application of compressed sensing for rapid MR imaging. 
% Lustig M, Donoho D, Pauly JM. Magn Reson Med. 2007 Dec;58(6):1182-95.
%
% Based on: Ricardo Otazo, NYU 2008


%2015 J Schoormans: added L2 constraint for magnitude eror of next frames
%2015: J SCHOORMANS MODIFIED FOR PARALLEL COMPUTING
%2015: J SCHOORMANS ADDED WAVELETS

disp('Non-linear conjugate gradient algorithm')
disp(' ---------------------------------------------')

% starting point
x=x0;

% line search parameters
maxlsiter = 150 ;
gradToll = 1e-3 ;
param.l1Smooth = 1e-15;	
param.E=tempE;
param.y=tempy;
param.slice=tempslice;

if isfield(param,'W2') %a second preconditioner has been added 
    disp('TGV!')
    param.lambda=param.lambda/3; %for TGV lambda =1/2
    param.lambda2=param.lambda*2;
else
    disp('not TGV')
    param.lambda2=0;
end

if ~isfield(param,'Prec')
    param.Prec=0; % no preconditiong
end

if ~isfield(param,'Secant')
    param.Secant=0; % no Secant line search
end

if ~isfield(param,'redFOV')
    param.redFOV=0; % no Secant line search
end
    
    

% param.Beta %can be either PR or FR

%alpha = 0.01;  
alpha=0.1;
beta = 0.4; %was 0.6
t0 = 1 ; 
k = 1;

% compute g0  = grad(f(x))
g0 = grad(x,param);
if param.Prec==0
    dx = -g0;
else
    Mi=calcPrec(x,param);
    dx= Mi.*(-g0);
end
f1old=0;
% iterations

while(1)

    % backtracking line-search
	f0 = objective(x,dx,0,param); if k==1; sf1(1)=f0; end;
	t = t0;
    f1 = objective(x,dx,t,param);
	lsiter = 0;
	if param.Secant==0
    while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:)))^2 & (lsiter<maxlsiter)
		lsiter = lsiter + 1;
		t = t * beta;
		[f1,L2Obj,L1Obj,L1Obj2] = objective(x,dx,t,param);
    end
    else %SECANT LINE SEARCH
%         while  alpha.^2.*  & (lsiter<maxlsiter)
% 		lsiter = lsiter + 1;
%         g3= grad(x,param)
%         g3=g3(:)'*dx;
%         alpha=alpha.*(eta)/(eta0-eta)
%         x=x+alpha.*dx;
%         eta0=eta;
%         
%         [f1,L2Obj,L1Obj,L1WObj,L1TVObj] = objective(x,dx,t,param);
%         end

    end
    
    cost(k+1)=f1;
    change(k+1)=(f1old-f1)/f1;
    f1old=f1;
	if lsiter == maxlsiter
		disp('Error - line search ...');
		return;
	end

	% control the number of line searches by adapting the initial step search
	if lsiter > 2, t0 = t0 * beta;end 
	if lsiter<1, t0 = t0 / beta; end

    % update x
	x = (x + t*dx);

	% print some numbers	
    if param.display,
        fprintf(' ite = %d, cost = %f |lsiter= %f|change=%f \n',k,f1,lsiter,change(k+1));
        
        figure(param.slice+100);
       subplot(1,2,1)
        
        sf1(k+1)=f1; sL2Obj(k+1)=L2Obj; sL1Obj(k+1)=L1Obj;sL1Obj2(k+1)=L1Obj2;
       
        hold on
        plot([0:k],sf1,'k-')
        plot([0:k],sL2Obj,'g-')
        plot([0:k],param.lambda*sL1Obj,'b-')
        plot([0:k],param.lambda2*sL1Obj2,'r-')

        hold off
        legend('f1 (sum)','L2','TV','TGV2')
        drawnow;
        s2=subplot(2,2,2);
        imshow(abs(x0(:,:,floor(size(x0,3)/2))),[]);
        title(s2,'zero-filled recon (one frame)')
        s3=subplot(2,2,4);
        imshow(abs(x(:,:,floor(size(x0,3)/2))),[]);
        title(s3,'CS recon (one frame)');
        drawnow;
        
%         saveas(gcf,['/home/jschoormans/lood_storage/divi/Projects/cosart/Matlab/Results/temp/temp' filename num2str(param.slice) '.jpg']);
if ~(k >= param.nite)          
clf; end

    end
    
    %conjugate gradient calculation
	g1 = grad(x,param);
    
    if param.Prec==0
    if strcmp(param.Beta,'FR')==1  
        bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    elseif strcmp(param.Beta,'PR')==1 
        bk = g1(:)'*(g1(:)-g0(:))/(g0(:)'*g0(:)+eps);
    elseif strcmp(param.Beta,'PR_restart')
        bk = g1(:)'*(g1(:)-g0(:))/(g0(:)'*g0(:)+eps);
        bk=max(real(bk),0); %assume bk should be real??
    elseif strcmp(param.Beta,'LS');
        bk = g1(:)'*(g1(:)-g0(:))/(-dx(:)'*g0(:)+eps);
    elseif strcmp(param.Beta,'LS_restart')
        bk = g1(:)'*(g1(:)-g0(:))/(-dx(:)'*g0(:)+eps);
        bk=max(real(bk),0); %assume bk should be real??
    elseif strcmp(param.Beta,'MLS');
        mu=0.25;
        yk=g1(:)-g0(:);
        bk0 =real(g1(:)'*(yk)/(-dx(:)'*g0(:)+eps))
        bkr=real((mu*(yk(:)'*yk(:))/(-dx(:)'*g0(:)+eps)^2)*g1(:)'*dx(:))
        bk=real(bk0-min(bk0,bkr)) %really not sure about the real part....
    elseif strcmp(param.Beta,'HHS'); %hybrid HS
        bFR = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
        bPR = g1(:)'*(g1(:)-g0(:))/(g0(:)'*g0(:)+eps);
        bk=max(0,min(bFR,bPR));
    elseif strcmp(param.Beta,'HZ')  %Hager and Zhang
                yk=g1(:)-g0(:);
                bk=(yk(:)-2*(dx(:)*(yk(:)'*yk(:))/(dx(:)'*yk(:))))'*(g1(:)/(dx(:)'*yk(:)))
                bk=real(bk)
    end
    
    
    
    g0 = g1;
	dx =  - g1 + bk* dx;
	k = k + 1;
	
    else %preconditiong

        Mi=calcPrec(x,param);
        Mi=real(Mi);
        s= Mi.*(-g1);
        bk = g1(:)'*(Mi(:).*(g1(:)-g0(:)))/(g0(:)'*(Mi(:).*g0(:))+eps);
        bk=real(bk);

        g0 = g1;
        dx =  s + bk* dx;
        k = k + 1;
    end
        
	% stopping criteria (to be improved)
	if (k > param.nite) || (norm(dx(:)) < gradToll), break;end

end
return;

function [res,L2Obj,L1Obj,L1Obj2] = objective(x,dx,t,param) %**********************************

% L2-norm part
Extdx=param.E*(x+t*dx);
w=Extdx-param.y;
L2Obj=w(:)'*w(:);


% L1-norm part
if param.lambda ~=0
    if param.redFOV==1
    x=x.*param.FOV;
    end
   w = param.W*(x+t*dx); 
   L1Obj = sum((conj(w(:)).*w(:)+param.l1Smooth).^(1/2));
else
    L1Obj=0;
end
if param.lambda2 ~=0
    if param.redFOV==1
    x=x.*param.FOV;
    end
   w = param.W2*(x+t*dx); 
   L1Obj2 = sum((conj(w(:)).*w(:)+param.l1Smooth).^(1/2));
else
    L1Obj2=0;
end



% objective function

res=L2Obj+param.lambda*L1Obj+param.lambda2*L1Obj2;



function g = grad(x,param)%***********************************************

% L2-norm part
Ex=param.E*x;
L2Grad = 2.*(param.E'*(Ex-param.y));


% L1-norm part
if param.lambda ~=0
    w = param.W*x;
    L1Grad = param.W'*(w.*(w.*conj(w)+param.l1Smooth).^(-0.5));
else
    L1Grad=0;
end

if param.lambda2 ~=0 
    w = param.W2*x;
    L1Grad2 = param.W2'*(w.*(w.*conj(w)+param.l1Smooth).^(-0.5));
else
    L1Grad2=0;
end

% composite gradient
g=L2Grad+param.lambda*L1Grad+param.lambda2*L1Grad2;
g(isnan(g))=0; %for adding sensitivity maps with zeroes

function Mi=calcPrec(x,param);
%    Mi would be the inverse of a transformed diagonal matrix with df''(dx) on each diagonal
gg1=grad2(x,param);
sum(gg1(:)>0)/(sum(gg1(:)<0)+sum(gg1(:)>0))
figure(99); imshow(gg1(:,:,5),[-5 5])

Mi=1./(gg1+eps); %PRECONDITIONER (inverse of diagonals of Hessian)

 
function g = grad2(x,param)%***********************************************

% L2-norm part
L2Grad = 2.*ones(size(x));

% L1-norm part
if param.lambda ~=0
    w = param.W*x;
    
    smooth=0.01; %smoothing parameter
    L1Grad= smooth/(w.*conj(w)+smooth).^(3/2);%%  so apparently f'' is a delta function???
    
else
    L1Grad=0; 
end

% composite gradient
g=L2Grad+param.lambda*L1Grad;
% g=L2Grad+L1Grad;

g(isnan(g))=0; %for adding sensitivity maps with zeroes

