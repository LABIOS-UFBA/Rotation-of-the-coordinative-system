function [N, Nt, D, V, T, w, r2, peak] = analyze_elements_MED(r, v, t, ME)
% -------------------------------------------------------------------------
% The analyze_elements_MED.m function is responsible for calculating the 
% MED variables for a one-dimensional time series
% 
% Input:
%     r = position time series
%     v = velocity time series
%     t = vector with time count
%     ME = vector with two columns, corresponding to the start (first
%          column) and end (second column) frames of the movement elements
%
% Output:
%     N = number of ME
%     Nt = number of ME per time
%     D = displacement of ME
%     V = average velocity of ME
%     T = duration of ME
%     w = similarity index of the ME with the Hoff curve
%     r2 = r-square of the ME with the Hoff curve
%     peak = number of peaks within each ME
%--------------------------------------------------------------------------

N = size(ME, 1);                                                           % Number of movement elements
Nt = N / (t(end) - t(1));                                                  % Number of movement elements per time

nanVec = nan(N, 1);                                                        % Creating the vectors to the output
D = nanVec; V = nanVec; T = nanVec; w = nanVec; r2 = nanVec; peak = nanVec;

for i = 1 : N
    
    D(i) = r(ME(i, 2)) - r(ME(i, 1));                                      % Determining the displacement of the i-ME
    T(i) = t(ME(i, 2)) - t(ME(i, 1));                                      % Determining the duration of the i-ME
    V(i) = mean(v(ME(i, 1) : ME(i, 2)));                                   % Determining the mean velocity of the i-ME
    
    [w(i), r2(i)] = ...
        fit_Hoff_MED(t(ME(i, 1) : ME(i, 2)), v(ME(i, 1) : ME(i, 2)));      % Determining the w and R-square of the fitting of the i-ME with the Hoff shape
    
    [~,pk] = findpeaks(abs(v(ME(i, 1) : ME(i, 2))));                       % Determining the number of peaks in the i-ME
    peak(i) = length(pk);

end
end
