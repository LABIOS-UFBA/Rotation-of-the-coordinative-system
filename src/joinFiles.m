function joinFiles(output_file, directory, file_type)
% -------------------------------------------------------------------------
% The joinFiles.m function is responsible for joining the files
% created in the loop into a single file and then deleting the
% temporary files
%
% Input:
%    output_file = output file name with full path
%    directory = path where the files created in the loop are located
%    file_type = type of file created in the loop (usually .csv)
%--------------------------------------------------------------------------

files = dir(fullfile(strcat(directory, file_type)));                       % Temporary files

num_files = length(files);

for i = 1 : num_files                                                      % Loop to concatenate the files
    if i == 1
        output = readtable([files(i).folder filesep files(i).name]);
    else
        aux = readtable([files(i).folder filesep files(i).name]);
        output = vertcat(output, aux); %#ok<AGROW>
    end
    delete([files(i).folder filesep files(i).name]);                       % Delete the temp files
end

rmdir(directory);

writetable(output, output_file);                                           % Write output table
end
