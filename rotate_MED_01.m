%------------------------------------------------------------------------
% 01 Code - MED Rotation Analysis
%
%
% This code applies the MED on a set of three-dimensional motion data for 
% different rotations of the Cartesian coordinate system.
%
%
% Authors: Silva, M.S.; Miranda, J.G.V.
% November 22, 2022
%--------------------------------------------------------------------------

addpath('src');

%% Setting filter parameters

min_D = 0.003;                                                             % Minimum displacement threshold
min_T = 0.1;                                                               % Minimum duration threshold
min_V = 0.01;                                                              % Minimum velocity threshold

lp = 10;                                                                   % Low pass filter
order = 4;                                                                 % Filter order

%% Configuring

task = [];                                                                 % Task used in this analysis (If empty, will use all tasks)
%task = "PS";
markerCM = "T10";                                                          % Center of Mass Marker
markerR = "RFIN";                                                          % Marker used as end point (Right)
markerL = "LFIN";                                                          % (Left)
folder = strcat('.', filesep, 'data', filesep);                            % Folder with the database

%% Starting the function that will apply the MED method to the data

files_list = dir(fullfile(folder, '**/*.c3d*'));                           % Lists all c3d files in the folder

if(~isempty(task))
    files_list = files_list(contains(string({files_list(:).name}), task)); % Filters the c3d files that have the task in filename
end

number_files = length(files_list);

mkdir(strcat('.', filesep, 'temp', filesep));                              % Make a temporary folder to save the output files of the parfor

parfor j = 1 : number_files

    file_path = [files_list(j).folder filesep files_list(j).name];
    name = file_path(52 : end);                                              

    [r_R, v_R, t] = treatDataMED_c3d(file_path, markerR, lp, order);       % Position, velocity and time vectors
    [r_L, v_L, ~] = treatDataMED_c3d(file_path, markerL, lp, order);
    
    if(sum(abs(v_R), 'all') > sum(abs(v_L), 'all'))                        % Choosing the marker that had the biggest movement
        r = r_R;
    else
        r = r_L;
    end
    
    [r_CM, ~, ~] = treatDataMED_c3d(file_path, markerCM, lp, order);
    r = r - r_CM(1,:);                                                     % Changing the origin of the coordinative system to the CM

    for xyrot = 0 : 0.2 : 90                                               % Loop for rotation of the coordinative system
        
        quat = quaternion([xyrot, 0, 0], 'eulerd', 'ZYX', 'point');
        
        r_rot = rotatepoint(quat, r);                                      % Position vector after the rotation
        v_rot = diff(r_rot) / (t(2) - t(1));        
        r_rot = r_rot(1:end-1,:);
        
        [output] = MED(name, [], r_rot, v_rot, t, min_D, min_T, min_V);    % Applying the MED
        
        output = struct2table(output);         
        output.Properties.VariableNames = ["ind","w", "r2", "peak", "nt"];        
        output.xyrot = repmat(xyrot, size(output, 1), 1);
        
        writetable(output, strcat('.', filesep, 'temp', filesep, ...       % Writing the temp file
            string(j), '_', string(xyrot), '_MED.csv')); 
    end
end

output_file = ...
    strcat('.', filesep, 'output', filesep, 'Rotate MED', task, '.csv');   % Joining temp files from the parfor iterations
directory = './temp/';
file_type = '*.csv';
joinFilesParfor(output_file, directory, file_type)                                
