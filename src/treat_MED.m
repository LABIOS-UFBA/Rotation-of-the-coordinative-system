function [r, v, t] = treat_MED(r, unit, sample_rate, lp, order)
% -------------------------------------------------------------------------
% The treatDataMED function is responsible correct the unit to meters,
% applying a low pass filter and calculate the velocity and time
%
% Input:
%     r = time series of the position (matrix)
%     unit = string with units in 'mm', 'cm', or 'm' (string)
%     sample_rate = sample_rate of the data (double)
%     lp = cutoff frequency of the low pass filter (int)
%     order = low pass filter order (int)
%
% Output:
%     r = position time series (matrix)
%     v = velocity time series (matrix)
%     t = vector with time count (vector)
%--------------------------------------------------------------------------

if isequal(unit, 'mm')                                                 % Correcting the scale to meters
    r = r / 1000;
elseif isequal(unit, 'cm')
    r = r / 100;
end

[b,a] = butter(order, (2*lp) / sample_rate, 'low');                        % Applying the low pass filter on the position time series
r = filtfilt(b, a, r);

v = diff(r) * sample_rate;                                                 % Calculating the velocity time series

r = r(1 : end - 1, :);

size = length(v);
t = (1 : size) / sample_rate;                                              % Creating the vector with the time count
t = t';

end
