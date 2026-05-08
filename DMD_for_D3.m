function [Phi, Lambda, b, Ubaser] = DMD_for_D3(Xsec,Xsec_prime,P,r,pt)
X0 = []; X1 = []; X2 = []; X3 = []; Xprime = [];
[~,N] = size(Xsec);
for i = 1:N
    X0 = [X0 Xsec{i}];
    X1 = [X1 P{i}(1)*Xsec{i}];
    X2 = [X2 P{i}(2)*Xsec{i}];
    X3 = [X3 P{i}(3)*Xsec{i}];
    Xprime = [Xprime Xsec_prime{i}];
end
X=[X0; X1; X2; X3];
[M,~] = size(X0);
% %% SVD 
[Ubase,Sigmabase,Vbase] = svd(Xprime,'econ');

assignin('base', 'Ubase', Ubase'*Ubase);
Ubaser = Ubase(:,1:r);
Sigmabaser = Sigmabase(1:r,1:r);
Vbaser = Vbase(:,1:r);

[U,Sigma,V] = svd(X,'econ');      % Step 1
% plot(cumsum(diag(Sigma))/sum(diag(Sigma)))
% assignin('base', 'M', M);
rp = r;
Ur = U(:,1:rp);
UA = U(1:M,:); 
UrA = U(1:M,1:rp);
UB1 = U(M+1:2*M,:);
UrB1 = U(M+1:2*M,1:rp);
UB2 = U(2*M+1:3*M,:);
UrB2 = U(2*M+1:3*M,1:rp);
UB3 = U(3*M+1:end,:);
UrB3 = U(3*M+1:end,1:rp);
Sigmar = Sigma(1:rp,1:rp);
Vr = V(:,1:rp);

deta = 0e0;
[~,n_eye] = size(Sigmar);
Atilde = Ubaser'*Xprime*Vr/(Sigmar+deta*eye(n_eye))*UrA'*Ubaser;    % Step 2
B1tilde = Ubaser'*Xprime*Vr/(Sigmar+deta*eye(n_eye))*UrB1'*Ubaser;    % Step 2
B2tilde = Ubaser'*Xprime*Vr/(Sigmar+deta*eye(n_eye))*UrB2'*Ubaser;    % Step 2
B3tilde = Ubaser'*Xprime*Vr/(Sigmar+deta*eye(n_eye))*UrB3'*Ubaser;    % Step 2

CombM = Atilde + pt(1).*B1tilde + pt(2).*B2tilde + pt(3).*B3tilde;

[W,Lambda] = eig(CombM);         % Step 3

%% Projected DMD
Phi =  Ubaser*W;       % Step 4
b = (W*Lambda);
