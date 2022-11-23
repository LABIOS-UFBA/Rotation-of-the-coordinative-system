function [ME] = segment_MED(t, r, v, min_D, min_T, min_V)
% -------------------------------------------------------------------------
% The segments_MED.m function is responsible for segmenting and selecting
% valid movement elements (ME) from a one-dimensional time series
%
% Input:
%     t = vector with the time count
%     r = vector with the time series of the position
%     v = vector with the time series of the velocity
%     min_D = minimum displacement of a valid element
%     min_T = minimum duration of a valid element
%     min_V = velocity corresponding to the instrumental error capture
%
% Output:
%     ME = vector with two columns, corresponding to the start (first
%          column) and end (second column) frames of the movement elements
% -------------------------------------------------------------------------
%% Find and classify critical points

[~, pk_M_index] = findpeaks(v);                                            % Checking the positive peaks in the velocity time series
[~, pk_m_index] = findpeaks(-v);                                           % Same for negative peaks (i.e. valleys)

pk_index = [pk_M_index; pk_m_index];                                       % Joining the indices into a single vector and sorting
pk_index = sort(pk_index);

pk_class = nan(length(pk_index),1);                                        % Creating a vector to classify the peaks

pk_class(v(pk_index) > min_V) = 1;                                         % Classifies peaks as 1, -1 and 0 depending on the velocity that they occur
pk_class(v(pk_index) < -min_V) = -1;
pk_class(abs(v(pk_index)) < min_V) = 0;

end_loop = length(pk_class);
i = 1;

if end_loop < 3 || sum(abs(pk_class)) == 0                                                          % If the file has less than 3 critical points or there isn't at least one peak +1 and -1, we consider as a data without valid movement
    ME = [];
    return;
end

%% Finds the points that cut the zero velocity between the critical points

while(true)                                                                % Loop to include "0" class peaks when there's a transition between a +1 peak to -1, or the opposite. (-1 to +1)
    if i == end_loop                                                       % The reason is that we'll use the zero peaks to cut the elements and if there's a transition without a peak passing through 0, ...
        break                                                              % ... we need to create one in the index of the value closes to 0 between these two peaks
    end
    
    if (pk_class(i) - pk_class(i + 1) == -2) || ...                        % Verify if there's two peaks occurring without a peak passing through the zero zone, i.e. between - min_V and + min_V
            (pk_class(i) - pk_class(i + 1) == 2 )
        [~, new_0] = min(abs(v(pk_index(i) : pk_index(i + 1))));           % Find the index of the velocity with the closest value to 0
        new_0 = new_0 + pk_index(i) - 1;
        pk_index = [pk_index(1 : i); new_0; pk_index(i + 1 : end)];        % Include this index between the two peaks
        pk_class = [pk_class(1 : i); 0; pk_class(i + 1 : end)];
        end_loop = end_loop + 1;
    end
    i = i + 1;
end

pk_class = abs(pk_class);                                                  % Changes the -1 classification to +1 because now we are interested only in the change from a 0 peak to a non-zero

%% Finds and fixes the beginnings and ends of elements

seg_class = diff(pk_class);                                                % Creates a vector that says when there's a change from a zero peak to a non-zero peak

seg_i = pk_index(seg_class == 1);                                          % seg_i selects the pk_index that corresponds to the beginning of a element
seg_f = pk_index(find(seg_class == -1) + 1);                               % seg_f is the same, but for the end of a element

if isempty(seg_i) || isempty(seg_f)
    ME = [];
    return;
end

if length(seg_i) == 1 && length(seg_f) == 1
    if seg_i(1) >= seg_f(1)
        ME = [];
        return;
    end
end

if seg_i(1) >= seg_f(1)                                                    % If first element end starts before first start (because of findpeaks functionality)
    [new0, pos0] = min(abs(v(1 : seg_f(1) - 1)));
    if new0 <= min_V                                                       % Find if there is a velocity point before the first end that is less than min_V and consider the first element start
        seg_i = [pos0; seg_i];
    else                                                                   % If not, delete this first element start
        seg_f(1) = [];
    end
end

if seg_i(end) >= seg_f(end)                                                % The same for the final of the time series
    [new0, pos0] = min(abs(v(seg_i(end) + 1 : end)));
    if new0 <= min_V
        seg_f = [seg_f; seg_i(end) + pos0 - 1];
    else
        seg_i(end) = [];
    end
end

ME = [seg_i, seg_f];

%% Selects the elements that pass through the filters

for i = 1 : size(ME, 1)                                                    % Loop to verify valid movement elements, i.e. elements with displacement and duration > min_D and min_T
    displacement = abs(r(ME(i, 2)) - r(ME(i, 1)));
    duration = t(ME(i, 2)) - t(ME(i, 1));
    
    if (displacement < min_D) || (duration < min_T)                        % If the i-element don't have the minimum displacement or duration, make the seg_i and seg_f = NaN to not consider it in the analysis
        ME(i, :) = nan(1, 2);
    end
end

ME(isnan(ME(:, 1)), :) = [];                                               % Delete the lines with nan values that corresponds to the movement elements that didn't passed the filters
ME(isnan(ME(:, 2)), :) = [];

end
