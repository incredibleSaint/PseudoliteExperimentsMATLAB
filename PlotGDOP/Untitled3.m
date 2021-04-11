Ptr_Gtr = 50e-3; % [W]
Ptr_dB = 10 * log10(Ptr_Gtr);

c = 3e8;
f = 1.57542e9;
lambda = c / f;


Prec = -148;
Prec_mW = 10 ^ (Prec / 10);
Prec_W = Prec_mW * 1e-3;

Ls = Prec_W / Ptr_Gtr;
d = lambda / (4 * pi * sqrt(abs(Ls)))

% Ls_dB = 10 * log10(Ls);

% Prec_dBW = Ptr_dB + Ls_dB; % еще влияние псевдолитов других
% Prec_dBm = Prec_dBW + 30;

