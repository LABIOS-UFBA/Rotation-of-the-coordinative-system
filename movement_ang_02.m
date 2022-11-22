%--------------------------------------------------------------------------
% 02 Code - Mean angle of movement
%
%
% This code checks the mean angle of motion from two approaches 
% (trajectory centroid and mean velocity angle)
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

for i = 1 : number_files

    file_path = [files_list(i).folder filesep files_list(i).name];
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

    ang_centroid = ...
        atan2(mean(r(:, 2)), mean(r(:, 1))) * 180/pi;
    
    ang_mean_vec_vel = ...
        atan2(diff(r(:, 2)), diff(r(:, 1))) * 180/pi;
    
    %% Passing from [-180, 180] to [0, 360]
    if ang_centroid < 0
        ang_centroid = ang_centroid + 360;
    end
    
    ang_mean_vec_vel(ang_mean_vec_vel < 0) = ...
        ang_mean_vec_vel(ang_mean_vec_vel < 0) + 360;
    
    %% Passing from [0, 360] to [0, 90]

    mod_cen = mod(ang_centroid,90);
    mod_mvv = mod(ang_mean_vec_vel,90);
    
    numb_cen = floor(ang_centroid/90);
    numb_mvv = floor(ang_mean_vec_vel/90);
    
    parity_cen = logical(mod(numb_cen,2));
    parity_mvv = logical(mod(numb_mvv,2));
    
    if parity_cen  
        mod_cen = abs(mod_cen - 90);
    end
    
    mod_mvv(parity_mvv) = abs(mod_mvv(parity_mvv)-90);
    
    output = struct;
    output.ind = name;
    output.ang_centroid = mod_cen;
    output.ang_mean_vec_vel = mean(mod_mvv);
    output.ang_std = std(mod_mvv);
    
    if i == 1
        c = mod_mvv;
        cmap = parula(90);
        cmap = cmap(1 : 90, :);                                            % dark blue to green (90 colors)
        pos_station = [0 0];
        c = (c - min(c)) / (max(c) - min(c)) * 90 + 1;                     % map to 90 colors
        scatter(r(1 : 200, 1), r(1 : 200, 2), [], c(1 : 200), 'filled');
        colormap(cmap)
        colorbar
    end
    
    writetable(struct2table(output), ...
        strcat('.', filesep, 'temp', filesep, string(i), '_MED.csv'));
   
end

output_file = ...
    strcat('.', filesep, 'output', filesep,'Movement Ang', task, '.csv');  % Joining temp files from the iterations
directory = './temp/';
file_type = '*.csv';
joinFiles(output_file, directory, file_type)                                
