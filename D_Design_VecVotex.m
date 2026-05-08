clc
clear
load Vorticity_opt.mat Ubaser Atilde B1tilde B2tilde B3tilde Y_Fish PARA Nx Ny
lx = Nx; ly = Ny;
X = Y_Fish;
r = 80;
%% Evaluate initial conditions
for k = 1:15
    S(k,:) = X{k}(:,1).';
    Input_Para(:,k) = [PARA{k}(1) PARA{k}(2) PARA{k}(3)].';
end

Set = [1 5 7 8 10 12 14 15];
[U,Sigma,V] = svd(S(Set,:),'econ');      % Step 1
rp = 4;
Ur = U(:,1:rp);
Sigmar = Sigma(1:rp,1:rp);
Vr = V(:,1:rp);
Beta = Ur*Sigmar

Sr = Beta*Vr.';

Output_Para = Beta.';

Xp = Input_Para(:,Set)';   % 15 x 3
Yp = Output_Para';         % 15 x 8
rp = size(Yp, 2);          % Number of outputs

% Step 1: Normalize input and output
mu_X = mean(Xp);
sigma_X = std(Xp);
X_norm = (Xp - mu_X) ./ sigma_X;

mu_Y = mean(Yp);
sigma_Y = std(Yp);
Y_norm =  (Yp - mu_Y) ./ sigma_Y;

% Step 2: Construct polynomial features [x1, x1^2, x2, x2^2, x3, x3^2]
x1 = X_norm(:,1);
x2 = X_norm(:,2);
x3 = X_norm(:,3);

X_poly = [ ...
    ones(size(x1)), ...        % constant term
    x1, x1.^2, ...             % x1, x1^2
    x2, x2.^2, ...             % x2, x2^2
    x3, x3.^2, ...                   % x3
];  % Resulting size: 15 x 8

% Step 3: Fit ridge regrssion models
Lambda = 1e-1;  % Regularization strength
models = cell(1, rp);
Y_norm_pred = zeros(size(Y_norm));

for i = 1:rp
    models{i} = fitrlinear(X_poly, Y_norm(:,i), ...
        'Learner','leastsquares', ...
        'Regularization','ridge', ...
        'Lambda', Lambda, ...
        'Solver','lbfgs');

    Y_norm_pred(:,i) = predict(models{i}, X_poly);
    R2 = corr(Y_norm(:,i), Y_norm_pred(:,i))^2;
    fprintf('Model %d R²: %.4f\n', i, R2);
end

% Step 4: Denormalize predictions
Y_pred = Y_norm_pred .* sigma_Y + mu_Y;


Pt1 = [-20:5:20];
Pt2 = [-30:5:20];
iconut = 0;
for ip = 1:length(Pt1)
    for jp = 1:length(Pt2)
        iconut = iconut +1

new_Input = [Pt1(ip) Pt2(jp) -1]; 
new_X_norm =  (new_Input - mu_X) ./ sigma_X;

x1_new = new_X_norm(1);
x2_new = new_X_norm(2);
x3_new = new_X_norm(3);

new_X_poly = [ ...
    1, ...
    x1_new, x1_new^2, ...
    x2_new, x2_new^2, ...
    x3_new, x3_new^2,...
];  % 1 x 8

new_Y_norm_pred = zeros(1, rp);
for i = 1:rp
    new_Y_norm_pred(:,i) = predict(models{i}, new_X_poly);
end

new_Y_pred = new_Y_norm_pred .* sigma_Y + mu_Y;


Sr_new = new_Y_pred*Vr.';

%% DMD Dynamics
N = 48;
pt = [Pt1(ip) Pt2(jp) -1]./1000;
CombM = Atilde + pt(1).*B1tilde + pt(2).*B2tilde + pt(3).*B3tilde;

[W,Lambda] = eig(CombM);         % Step 3

dt=1/24*(1/2);
tspan = [0:dt:(N-1)*dt];
omega = log(Lambda)/dt;
wx = imag(diag(omega));

%% Projected DMD
Phi =  Ubaser*W;       % Step 4
b = (W*Lambda);

XPm(:,1) = Sr_new.';

b=b\(Ubaser'*XPm(:,1));

[w_st, idx] = sort(wx);
Phi_st = Phi(:,idx);
DiaOme = diag(omega);
omega_st = diag(DiaOme(idx));
b_st = b(idx);

Err = 0;
for k = 32 % 16, 32, 48
    Y = zeros(ly*lx,1);
    w = [];
    for i = 1:r
        if real(omega_st(i,i))>0
            omegai = omega_st(i,i) - real(omega_st(i,i));
        else
            omegai = omega_st(i,i);
        end
        Y = Y + Phi_st(:,i)*exp(omegai*tspan(k))*b_st(i);
        w = [w abs(omegai)];
    end  
    Yshape = reshape(real(Y),ly,lx);
%     
    [maxval, maxidx] = max(Yshape, [], 'all', 'linear');
    [minval, minidx] = min(Yshape, [], 'all', 'linear');

    Para_list(ip,jp,:) = new_Input;
    Vmax(ip,jp) = maxval-minval;
    MeanV(ip,jp) = mean(abs(Yshape(:)));
end

    end
end
V_shift = Vmax./max(Vmax,[],'all');
V_max = MeanV./max(MeanV,[],'all');

for k = 1:15
    Sshape = reshape(X{k}(:,N),ly,lx);
    [Smaxval, Smaxidx] = max(Sshape, [], 'all', 'linear');
    [Sminval, Sminidx] = min(Sshape, [], 'all', 'linear');
    SVmax(k) = Smaxval-Sminval;
    MeanS(k) = mean(abs(Sshape(:)));
end
VS_shift = SVmax/max(SVmax);
VS_max = MeanS/max(MeanS);

[SV_sort,S_index] = sort(VS_shift,'descend');

F = [V_shift(:), V_max(:)];

n = size(F,1);
isPareto = true(n,1);  % Assume all points are Pareto

for i = 1:n
    for j = 1:n
        if all(F(j,:) <= F(i,:)) && any(F(j,:) < F(i,:))
            isPareto(i) = false;
            break;
        end
    end
end

F_pareto = F(isPareto,:);

P = reshape(Para_list, length(Pt1)*length(Pt2), 3);
P_pareto = P(isPareto,:);

[Fsort, Findex] = sort(F_pareto(:,1));

plot(V_shift(:), V_max(:), 'bo'); hold on
plot(Fsort, F_pareto(Findex,2), 'ro-', 'LineWidth', 2);
xlabel('Objective 1'); ylabel('Objective 2');
legend('All points','Pareto front'); grid on






