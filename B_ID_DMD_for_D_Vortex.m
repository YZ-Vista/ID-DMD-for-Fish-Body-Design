clc
clear

load Fish_DV.mat Y_Fish PARA Nx Ny;
lx = Nx; ly = Ny;
X = Y_Fish;
r = 200; %200;
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
    X{xi} = Xdn{xi} + EX;
end

indx = [1 4 5 8 9 10 12 14 15]; % indx = [1:2:16];
for i = 1:length(indx)
    k=indx(i);
    Xc{i} = X{k}(:,1:ntrunc-1);
    Xc_prime{i} = X{k}(:,2:ntrunc);
    P{i} = [PARA{k}(1)/1000 PARA{k}(2)/1000 PARA{k}(3)/1000];
end

for s = 3
pt = [PARA{s}(1)/1000 PARA{s}(2)/1000 PARA{s}(3)/1000];
[Phi, Lambda, b, Ubaser] = DMD_for_D3(Xc,Xc_prime,P,r,pt);

dt=1/24*(1/2);
tspan = [0:dt:(N-1)*dt];
omega = log(Lambda)/dt;
wx = imag(diag(omega));

b=b\(Ubaser'*X{s}(:,1));

[w_st, idx] = sort(wx);
Phi_st = Phi(:,idx);
DiaOme = diag(omega);
omega_st = diag(DiaOme(idx));
b_st = b(idx);

%% DMD
Err = 0;
for k = 32 % 16, 32, 48
    Y = zeros(ly*lx,1);
    w = [];
    tic
    for i = 1:r
        if real(omega_st(i,i))>0
            omegai = omega_st(i,i) - real(omega_st(i,i));
        else
            omegai = omega_st(i,i);
        end
        Y = Y + Phi_st(:,i)*exp(omegai*tspan(k))*b_st(i);
        w = [w abs(omegai)];
    end 
    toc

    fhandle = PlotFishXV(real(reshape(Y,ly,lx)),3,1)
    axis equal off; drawnow 

    Vtest = X{s}(:,k);
    fhandle = PlotFishXV(reshape(Vtest,ly,lx),3,2)
    axis equal off; drawnow 

%%%%%%%%%%%%%% err
Err = Err + abs(Y-Vtest)./max(abs(Vtest));
% AErr = Err/N;
AErr = Err/1;
fhandle = PlotFishErr(reshape(AErr,ly,lx),3,3)
axis equal off; drawnow

end

end



