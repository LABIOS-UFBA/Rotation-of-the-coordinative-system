%% Main code
%
% This code evaluate the effect between the coordinate system with inertial
% or non-inertial referential (Joint coordinative system and 
% Head coordinative system) in human random movements
%
%
% Authors: Silva, M.S.; Miranda, J.G.V.
% September 08, 2022

addpath('src');

%% Setting filter parameters

limD = 0.003;               % Minimum displacement threshold
limT = 0.1;                 % Minimum duration threshold
limV = 0.01;                % Minimum velocity threshold

lp = 10;                    % Low pass filter
order = 4;                  % Filter order
filters = [limD, limT, limV, lp, order];

%% Configuring

%task = [];                                                                 % Task used in this analysis
task = "PS";
JCS = ["RWRA"; "LWRA"];
head = ["RBHD"; "RFHD"];
marker = ["RFIN"; "LFIN"];                                                 % Marker used as end point
folder = strcat('.', filesep, 'data', filesep);                            % Folder with the database

%% Starting the function that will apply the MED method to the data

files_list = dir(fullfile(folder, '**/*.c3d*'));                           % Lists all c3d files in the folder

if(~isempty(task))
    files_list = files_list(contains(string({files_list(:).name}), task)); % Filters the c3d files that have the task in filename
end

number_files = length(files_list);

mkdir(strcat('.', filesep, 'temp', filesep));                             % Make a temporary folder to save the output files of the parfor

for j = 1 : number_files
    
    file_path = [files_list(j).folder filesep files_list(j).name];
    
    ind = file_path(52 : 53);
    
    [r_inertial, v_inertial, t_inertial] = treatDataMED(file_path, ...
        marker(1), filters);
    
    [r_inertial2, v_inertial2, ~] = treatDataMED(file_path, marker(2), filters);
    
    if(mean(v_inertial) < mean(v_inertial2))
        [r_joint, v_joint, ~] = treatDataMED(file_path, JCS(2), filters);
        r_inertial = r_inertial2;
        v_inertial = v_inertial2;
    else
        [r_joint, v_joint, ~] = treatDataMED(file_path, JCS(1), filters);
    end
    
    r_JCS = r_inertial - r_joint;
    v_JCS = v_inertial - v_joint;
    
    [r_back_head, ~, ~] = treatDataMED(file_path, head(1), filters);
    [r_front_head, ~, ~] = treatDataMED(file_path, head(2), filters);
    
    r_head = r_front_head - r_back_head;
    ang = zeros(size(r_head, 1), 3);
    ang(:, 1) = - atan2(r_head(:, 3), r_head(:, 2))*180/pi;
    
    quat1 = quaternion(ang, 'eulerd', 'XYZ', 'point');
    r_head = rotatepoint(quat1, r_head);
    
    ang = zeros(size(r_head, 1), 3);
    ang(:, 3) = atan2(r_head(:, 1), r_head(:, 2))*180/pi;
    
    quat2 = quaternion(ang, 'eulerd', 'XYZ', 'point');
    %r_head = rotatepoint(quat2, r_head);
       
    r_HCS = r_inertial - r_back_head;
    r_HCS = rotatepoint(quat1, r_HCS);
    r_HCS = rotatepoint(quat2, r_HCS);
    
    v_HCS = diff(r_HCS)/(t_inertial(2) - t_inertial(1));
    r_HCS = r_HCS(1 : length(r_HCS) - 1, :);
    t_HCS = t_inertial(1 : length(t_inertial) - 1);
    
    [output_inertial] = MED(ind, r_inertial, v_inertial, t_inertial, 1, filters);
    [output_JCS] = MED(ind, r_JCS, v_JCS, t_inertial, 2, filters);
    [output_HCS] = MED(ind, r_HCS, v_HCS, t_HCS, 3, filters);
    
    output = struct2table([output_inertial; output_JCS; output_HCS]);
    
    output.Properties.VariableNames = ["ind","cs", "w", "r2", "peak", "nt"];
    
    writetable(output, strcat('.', filesep, 'temp', filesep, string(j), '_MED.csv'));
end

outFile = readtable(strcat('.', filesep, 'temp', filesep, string(1), '_MED.csv'));
delete(strcat('.', filesep, 'temp', filesep, string(1), '_MED.csv'));

for j = 2 : number_files
    aux = readtable(strcat('.', filesep, 'temp', filesep, string(j), '_MED.csv'));
    outFile = vertcat(outFile, aux);
    delete(strcat('.', filesep, 'temp', filesep, string(j), '_MED.csv'));
end

rmdir(strcat('.', filesep, 'temp'));

if(isempty(task))
    writetable(outFile, strcat('.', filesep, 'output', filesep, 'random_allTasks_MED.csv'));
else
    writetable(outFile, strcat('.', filesep, 'output', filesep, 'random_', task, '_MED.csv'));
end