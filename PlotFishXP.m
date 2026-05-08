function fhandle = PlotFishXP(VORT,s,i)

fhandle = figure (1)
subplot(1,s,i)

V2 = VORT;

% normalize values... not symmetric
vortmax = 1.5;
vortmin = -1.5;
maxval = max(V2(:));
minval = min(V2(:));
V2(V2>vortmax) = vortmax;
V2(V2<vortmin) = vortmin;

% A_rotated = rot90(V2);
imagesc(V2)
