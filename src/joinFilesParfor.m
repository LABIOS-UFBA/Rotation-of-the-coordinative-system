function joinFilesParfor(output_file, directory, file_type)
% -------------------------------------------------------------------------
% The joinFilesParfor.m function is responsible for joining the files
% created in the parfor loop into a single file and then deleting the
% temporary files
%
% Input:
%    output_file = output file name with full path
%    directory = path where the files created in the loop are located
%    file_type = type of file created in the loop (usually .csv)
%--------------------------------------------------------------------------

files = dir(fullfile(strcat(directory, file_type)));                       % Temporary files

num_files = length(files);
num_cores = feature('numcores');

div = floor(num_files / num_cores);

par_files = mat2cell(files, ...
    [repmat(div, num_cores - 1, 1); num_files - (num_cores - 1)*div], 1);

parfor core = 1 : 6
    i_files = par_files{core};
    num_i_files = length(i_files);
    
    for i = 1 : num_i_files                                                % Loop to concatenate the files
        if i == 1
            i_output = ...
                readtable([i_files(i).folder filesep i_files(i).name]);
        else
            aux = readtable([i_files(i).folder filesep i_files(i).name]);
            i_output = vertcat(i_output, aux);
        end
        delete([i_files(i).folder filesep i_files(i).name]);               % Delete the temp files
    end
    
    writetable(i_output, strcat(directory,string(core),'.csv'));           % Write output table
end

for core = 1 : 6
    if core == 1
        output = readtable(strcat(directory,string(core),'.csv'));
    else
        aux = readtable(strcat(directory,string(core),'.csv'));
        output = vertcat(output, aux); %#ok<AGROW>
    end
    delete(strcat(directory,string(core),'.csv'));
end

rmdir(directory);

writetable(output, output_file);                                           % Write output table
end
