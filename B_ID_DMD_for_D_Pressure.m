clc
clear

load Fish_DP.mat Y_Fish PARA Nx Ny;
lx = Nx; ly = Ny;
X = Y_Fish;
r = 200;
[~,nm] = size(X);
[M,N] = size(X{1});
ntrunc = round(1*N);
EX=[];
A=0e-2;
for ni=1:N
randn('state',ni)
EX(:,ni) = 2*A*randn(1,M)-A;
end
for xi=1:nm
    Xdn{xi} = X{xi};
    X{xi} = Xdn{xi}+EX;
end

indx = [1 4 5 8 9 10 12 14 15];
for i = 1:length(indx)
    k=indx(i);
    Xc{i} = X{k}(:,1:ntrunc-1);
    Xc_prime{i} = X{k}(:,2:ntrunc);
    P{i} = [PARA{k}(1)/1000 PARA{k}(2)/1000 PARA{k}(3)/1000];
end
s = 3; % 24
pt = [PARA{s}(1)/1000 PARA{s}(2)/1000 PARA{s}(3)/1000];
[Phi, Lambda, b, Ubaser] = DMD_for_D3(Xc,Xc_prime,P,r,pt);

dt=1/24*(1/2);;
tspan = [0:dt:(N-1)*dt];
omega = log(Lambda)/dt;
wx = abs(diag(omega));

b=b\(Ubaser'*X{s}(:,1));

%% DMD
Err = 0;
for k = 32 %
    Y = zeros(ly*lx,1);
    w = [];
    for i=1:r
        if real(omega(i,i))>0
            omegai = omega(i,i)-real(omega(i,i));
        else
            omegai = omega(i,i);
        end
        Y = Y+Phi(:,i)*exp(omegai*tspan(k))*b(i);
        w = [w abs(omegai)];
    end  
    fhandle = PlotFishXP(real(reshape(Y,ly,lx)),3,1)
    axis equal off; drawnow 
    
    Vtest = X{s}(:,k);
    fhandle = PlotFishXP(reshape(Vtest,ly,lx),3,2)
    axis equal off; drawnow 

%%%%%%%%%%%%%% err
Err = Err + abs(Y-Vtest)./max(abs(Vtest));
AErr = Err/1;
fhandle = PlotFishErr(reshape(AErr,ly,lx),3,3)
axis equal off; drawnow

end
% close(anim);