function [F,phase0] = analog( bi_codeX4, delta_f_doppl,phase0,sampleCount, ...
                                len_CA)
A_t = 1;
%c = 3*1e8;
%V_rad = 1e3;
%T_ranging_code = 0.001;%ms
T_RC = 0.001;%ms
%f_0 = 1561.098 * 1e6;
%delta_f_doppl = f_0 * ( V_rad / c );
delta_w_doppl = 2 * pi * delta_f_doppl;
% t = T_RC/length(bi_codeX4) : T_RC/length(bi_codeX4): T_RC;
% t=1:Freq_Sample*2046;
% t=t*(1/(Freq_Sample*2.046e6));
% phase = delta_w_doppl*t+phase0;
% F = A_t*bi_codeX4.*exp(1j*phase);
% phase0 = phase(end);
% t = T_ranging_code/length(bi_codeX4) : T_ranging_code/length(bi_codeX4): T_ranging_code;% f=2,046*Fs MHz !!C/A code
% if phase == 0
%     t = T_RC/length(bi_codeX4) : T_RC/length(bi_codeX4): T_RC;
%     first_time = 0;
% else
%    first_time = phase/delta_w_doppl;
%     t = first_time : T_RC/length(bi_codeX4) : first_time + T_RC-T_RC/length(bi_codeX4);
% 
len = len_CA * sampleCount;
t = 1 : len;
t = t * (1 / (sampleCount * len_CA * 1000));
F = A_t * bi_codeX4(1 : len) .* exp(1j * (delta_w_doppl * t + phase0));
% phase = delta_w_doppl*(T_RC+T_RC/length(bi_codeX4));
phase = delta_w_doppl * t + phase0;
phase0 = phase(end);
end
%   t = T_RC/length(bi_codeX4) : T_RC/length(bi_codeX4): T_RC;
% F = A_t*bi_codeX4.*exp(1j*delta_w_doppl*t)*exp(1j*phase);
% phase = delta_w_doppl*(t(end))+phase;
