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
% -------------------------------------------------------------------------

N = size(ME, 1);                                                           % Number of movement elements
Nt = N / (t(end) - t(1));                                                  % Number of movement elements per time

zero = zeros(N, 1);                                                        % Creating the vectors to the output
D = zero; V = zero; T = zero; w = zero; r2 = zero; peak = zero;

for i = 1 : N                                                              % Loop for each i-ME
    
    v_i = v(ME(i, 1) : ME(i, 2));                                          % Time series of the velocity of the i-ME
    t_i = t(ME(i, 1) : ME(i, 2));                                          % Time counting of the i-ME
    
    D(i) = r(ME(i, 2)) - r(ME(i, 1));                                      % Displacement of the i-ME
    T(i) = t_i(end) - t_i(1);                                              % Duration of the i-ME
    V(i) = mean(v_i);                                                      % Mean velocity of the i-ME
    
    t_Hoff = linspace(0, 1, length(t_i));                                  % Creates the Hoff curve corresponding to the same T and V of the ME
    Hoff = V(i)*30*((t_Hoff.^4) - 2*(t_Hoff.^3) + (t_Hoff.^2));
    
    dvHoff = Hoff' - v_i;                                                  % Similarity index (w) comparing with Hoff shape
    w(i) = std(dvHoff) / abs(V(i));
    
    corr = corrcoef(Hoff, v);                                              % R-square comparing with Hoff shape
    r2(i) = corr(1, 2).^2;
    
    [~,pk] = findpeaks(abs(v(ME(i, 1) : ME(i, 2))));                       % Number of peaks in the i-ME
    peak(i) = length(pk);
    
end
end
