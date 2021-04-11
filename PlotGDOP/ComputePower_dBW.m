function [Prec]= ComputePower_dBW(Pseudolite, userPos)
    
Ptr_Gtr = 50e-3; % [W]
Ptr_dB = 10 * log10(Ptr_Gtr);

c = 3e8;
f = 1.57542e9;
lambda = c / f;

xsat = Pseudolite.x;
ysat = Pseudolite.y;
zsat = Pseudolite.z;

x = userPos.x;
y = userPos.y;
z = userPos.z;

d = sqrt(sum(([xsat ysat zsat] - [x y z]) .^ 2))

Ls = (lambda / (4 * pi * d)) ^ 2;
Prec = Ls * Ptr_Gtr;
% Ls_dB = 10 * log10(Ls);
% Prec_dBW = Ptr_dB + Ls_dB; % еще влияние псевдолитов других
%Prec_dBm = Prec_dBW + 30;

end

% d = sqrt(Ls) * lambda / 4 / pi 