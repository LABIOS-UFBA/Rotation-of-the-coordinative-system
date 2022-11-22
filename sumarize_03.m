%--------------------------------------------------------------------------
% 03 Code - Sumarize MED rotation and Mean angle of movement
%
%
% This code checks which rotation angle obtained the minimum for the MED 
% variables and concatenates with the average movement angles
%
%
% Authors: Silva, M.S.; Miranda, J.G.V.
% November 22, 2022
%--------------------------------------------------------------------------

rotate = readtable('output/Rotate MED.csv');
ang = readtable('output/Movement Ang.csv','delimiter',',');

files = unique(rotate.ind);

output = struct;

for i = 1:length(files)
    aux = rotate(strcmp(rotate.ind, files(i)),:);
    
    [~, w_i] = min(aux.w);
    [~, peak_i] = min(aux.peak);
    [~, nt_i_max] = max(aux.nt);
    [~, nt_i_min] = min(aux.nt);
    
    output.w_min(i,1) = aux.xyrot(w_i);
    output.peak_min(i,1) = aux.xyrot(peak_i);
    output.nt_min(i,1) = aux.xyrot(nt_i_min);
    output.nt_max(i,1) = aux.xyrot(nt_i_max);
    output.ang_centroid(i,1) = ang.ang_centroid(strcmp(ang.ind, files(i)));
    output.ang_vec_vel(i,1) = ang.ang_mean_vec_vel(strcmp(ang.ind, files(i)));
    output.ang_std(i,1) = ang.ang_std(strcmp(ang.ind, files(i)));
    
end

writetable(struct2table(output),'output/Sumarize MED Ang.csv');