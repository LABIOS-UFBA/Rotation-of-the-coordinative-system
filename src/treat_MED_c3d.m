function [r, v, t] = treat_MED_c3d(file_path, marker, lp, order)
% -------------------------------------------------------------------------
% The treatDataMED_c3d function is responsible for reading the c3d file,
% selecting one marker of interest and applying a low pass filter
%
% Input:
%     file_path = location of .c3d file
%     marker = desired marker name (as written in the c3d file)
%     lp = cutoff frequency of the low pass filter
%     order = low pass filter order
%
% Output:
%     r = position time series
%     v = velocity time series
%     t = vector with time count
% -------------------------------------------------------------------------

btk_acq = btkReadAcquisition(file_path);                                   % Reading c3d file
btk_markers = btkGetMarkers(btk_acq);
btk_unit = btkGetPointsUnit(btk_acq, 'marker');

r = btk_markers.(marker);                                                  % Selecting the desired marker
if isequal(btk_unit, 'mm')                                                 % Correcting the scale to meters
    r = r / 1000;
elseif isequal(btk_unit, 'cm')
    r = r / 100;
end

sample_rate = btkGetPointFrequency(btk_acq);
[b,a] = butter(order, (2*lp) / sample_rate, 'low');                        % Applying the low pass filter on the position time series
r = filtfilt(b, a, r);

v = diff(r) * sample_rate;                                                 % Calculating the velocity time series

r = r(1 : end - 1, :);

size = length(v);
t = (1 : size) / sample_rate;                                              % Creating the vector with the time count
t = t';

end
