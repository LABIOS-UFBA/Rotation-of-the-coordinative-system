function [w,r2]=fit_Hoff_MED(t,v)
% -------------------------------------------------------------------------
% The fit_Hoff_MED.m function is responsible for calculating the similarity
% index and r-square of the fitting between the movement element and the
% Hoff curve
%
% Input:
%     t = vector with time count of the ME
%     v = velocity time series of the ME
%
% Output:
%     w = similarity index of the ME with the Hoff curve
%     r2 = r-square of the ME with the Hoff curve
%--------------------------------------------------------------------------

v_mean = mean(v);
t_Hoff=linspace(0,1,length(t));                                            % Creates the Hoff curve corresponding to the same displacement and mean velocity of the ME
Hoff=v_mean*30*( (t_Hoff.^4) -2*(t_Hoff.^3) + (t_Hoff.^2));

dvHoff=Hoff'-v;                                                            % Calculate the similarity index (w)
w=std(dvHoff)/abs(v_mean);

r2=corrcoef(Hoff,v);                                                       % Calculate the r-square
r2=r2(1,2).^2;

end
