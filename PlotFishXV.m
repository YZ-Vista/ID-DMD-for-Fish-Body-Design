function fhandle = PlotFishXV(VORT,s,i)

fhandle = figure (1)
subplot(1,s,i)

V2 = VORT;

% normalize values... not symmetric
% 
vortmin = -20;
vortmax = 20;
minval = min(V2(:));
maxval = max(V2(:));
V2(V2>vortmax) = vortmax;
V2(V2<vortmin) = vortmin;

% A_rotated = rot90(V2);
imagesc(V2)
