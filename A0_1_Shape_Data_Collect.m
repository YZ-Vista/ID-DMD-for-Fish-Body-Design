clc
clear

% Set the base folder
currentFilePath = fileparts(mfilename('fullpath'));
basePath = fullfile(currentFilePath, 'Fishes dataset');
folders = dir(basePath);
isSubfolder = [folders.isdir] & ~ismember({folders.name}, {'.', '..'});
subfolderNames = {folders(isSubfolder).name};

% Sort subfolder names alphabetically
subfolderNames = sort(subfolderNames);

% Preallocate cell arrays
X = cell(1, numel(subfolderNames));
Y = cell(1, numel(subfolderNames));

% Loop through each subfolder and load the data
for i = 1:numel(subfolderNames)
    dataFile = fullfile(basePath, subfolderNames{i}, 'body_data.mat');
    s = load(dataFile);  % Load as struct to avoid variable overwrite
    X{i} = s.x;
    Y{i} = s.y;
end

save Fish_Shape.mat X Y 




