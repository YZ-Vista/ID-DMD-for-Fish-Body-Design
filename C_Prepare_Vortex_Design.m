clc
clear

load Fish_DV.mat Y_Fish PARA Nx Ny;
lx = Nx; ly = Ny;
X = Y_Fish;
r = 80;
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

indx = [1 4 5 6 8 10 12 14 15]; % indx = [1:2:16];
for i = 1:length(indx)
    k=indx(i);
    Xc{i} = X{k}(:,1:ntrunc-1);
    Xc_prime{i} = X{k}(:,2:ntrunc);
    P{i} = [PARA{k}(1)/1000 PARA{k}(2)/1000 PARA{k}(3)/1000];
end

for s = 7
pt = [PARA{s}(1)/1000 PARA{s}(2)/1000 PARA{s}(3)/1000];
[Ubaser, Atilde, B1tilde, B2tilde, B3tilde] = DMD_for_D3_Design(Xc,Xc_prime,P,r,pt);
end

save Vorticity_opt.mat Ubaser Atilde B1tilde B2tilde B3tilde Y_Fish PARA Nx Ny

