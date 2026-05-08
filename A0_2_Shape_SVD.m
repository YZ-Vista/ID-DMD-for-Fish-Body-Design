clc
clear
load Fish_Shape.mat X Y

for iter = 1:15
    x = X{iter};
    y = Y{iter};

%% extend open curve
x_ext = 2*194+1 - x(201:end);
y_ext = y(201:end);

x_comb = [x(1:200); x_ext].';
y_comb = [y(1:200); y_ext].';

S(iter,:) = y_comb;
end

[U,Sigma,V] = svd(S,'econ');
rp =4;
Ur = U(:,1:rp);
Sigmar = Sigma(1:rp,1:rp);
Vr = V(:,1:rp);
Beta = Ur*Sigmar
Sr = Beta*Vr.';

figure (1)
for iter = [14]; % [1:15]
    y_pre = Sr(iter,:);
    y_true = S(iter,:);
    
    x_down = 2*194+1 - x_comb(201:end);
    x_recon = [x_comb(1:200) x_down];
    
    y_down_pre = y_pre(201:end);
    y_recon_pre = [y_pre(1:200) y_down_pre];
    
    y_down_true = y_true(201:end);
    y_recon_true = [y_true(1:200) y_down_true];
    
    plot(x_recon, y_recon_pre,'+r', 'LineWidth', 2);
    hold on
    plot(x_recon, y_recon_true,'.b', 'LineWidth', 2);
    hold on
    Err = sum(abs(y_recon_true - y_recon_pre))./sum(abs(y_recon_true-98))
end

B1 = Beta(:,1);
B2 = Beta(:,2);
B3 = Beta(:,3);
B4 = Beta(:,4);

save Para_order.mat B1 B2 B3 B4













