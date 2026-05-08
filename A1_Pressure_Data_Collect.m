clc
clear
load Para_order.mat B2 B3 B4
% Set the base folder
currentFilePath = fileparts(mfilename('fullpath'));
basePath = fullfile(currentFilePath, 'Fishes dataset');
folders = dir(basePath);
isSubfolder = [folders.isdir] & ~ismember({folders.name}, {'.', '..'});
subfolderNames = {folders(isSubfolder).name};

% Sort subfolder names alphabetically
subfolderNames = sort(subfolderNames);

FishD2 = B2;
FishD3 = B3;
FishD4 = B4;

for s=1:15
    dataFile = fullfile(basePath, subfolderNames{s}, 'pressure.mat');
    load(dataFile);  % Load as struct to avoid variable overwrite

    firstVarName = sprintf('pressure_frame%d', 1);
    firstMatrix = eval(firstVarName);  % Convert variable name string to actual variable
    Frame_rotated = rot90(pressure_frame1);
    [Ny, Nx] = size(Frame_rotated);
    Fish = zeros(Ny, Nx, 48);
    Fish(:,:,1) = Frame_rotated;
    Y_Fish{s}(:,1) = reshape(Fish(:,:,1),Ny*Nx,1); 
    fhandle = PlotFishXP(Fish(:,:,1),1,1);
    axis equal off; drawnow
    
    % Loop through the rest
    for t = 1:47
        varName = sprintf('pressure_frame%d', t+1);
        Fish_ori = eval(varName);  % Evaluate the variable name
        Fish(:,:,t+1) = rot90(Fish_ori);
        Y_Fish{s}(:,t+1) = reshape(Fish(:,:,t+1),Ny*Nx,1);  
        fhandle = PlotFishXP(Fish(:,:,t+1),1,1);
        axis equal off; drawnow
    end
    PARA{s} = [FishD2(s) FishD3(s) FishD4(s)];
end

save Fish_DP.mat Y_Fish PARA Nx Ny
