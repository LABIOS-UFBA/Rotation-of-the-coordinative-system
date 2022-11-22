function [variable_table] = MED(name, flag, r, v, t, min_D, min_T, min_V)
% -------------------------------------------------------------------------
% The MED.m function is responsible for calculating the MED variables to an
% n-dimensional file and exporting as output
% 
% Input:
%     name = name of the file
%     flag = any flag that you want to put inside the table
%     r = position time series
%     v = velocity time series
%     t = vector with time count
%     min_D = minimum displacement of a valid element
%     min_T = minimum duration of a valid element
%     min_V = velocity corresponding to the instrumental error capture
%
% Output:
%     variable_table = table with MED variables for output
%--------------------------------------------------------------------------

variable_table = struct;

dim = size(r, 2);                                                          % Number of dimensions of the data

n = nan(dim, 1); nt = n; w = n; r2 = n; peak = n;

for i = 1 : dim
    ME_i = segment_MED(t, r(:, i), v(:, i), min_D, min_T, min_V);          % Finds the frames that occur valid motion elements in the i-dimension
    
    if isempty(ME_i)
        continue
    end
    
    [n(i), nt(i), ~, ~, ~, waux, r2aux, ...                                % Check the MED variables for this i-dimension
        peakaux] = analyze_elements_MED(r(:, i), v(:, i), t, ME_i);
    w(i) = mean(waux);
    r2(i) = mean(r2aux);
    peak(i) = mean(peakaux);
end

if sum(n) > 1
    nt_mean = sum(nt.*n) / sum(n);                                             % Calculating mean of the MED variables of each dimension
    w_mean = sum(w.*n) / sum(n);
    r2_mean = sum(r2.*n) / sum(n);
    peak_mean = sum(peak.*n) / sum(n);
else
    nt_mean = nan;
    w_mean = nan;
    r2_mean = nan;
    peak_mean = nan;
end

variable_table(1, 1).ind = name;                                           % Filling in the variables table
if(~isempty(flag))
    variable_table(1, 1).flag = flag;
end
variable_table(1, 1).w_inertial = w_mean;
variable_table(1, 1).r2_inertial = r2_mean;
variable_table(1, 1).peak_inertial = peak_mean;
variable_table(1, 1).nt_inertial = nt_mean;

end
