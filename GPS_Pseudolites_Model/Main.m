% Модель, имитирующая расчет позиции пользователя в разных точках
% при использовании ЛНС.
clear;
addpath('Functions')

% -- Parameters ----
CN0  = [80 42 35 30 40 35];% dB-Hz 

threshold = [0.95];

exp_num = 1;

quant_accum = 5;

sig_dur = 1; % sec

sample_freq = 4;

delta_f_doppl = 0;
% -- Constants -----
c = 2.99792458e8;
len_CA = 1023;
bandwidth = 2 * len_CA * 1000;
%-------------------

% d = 1000;
% x = d / tand(60);
% S = 1 / 2 * 2 * d * 2 * x;
% height = d;
% 
% Pseudolite{1}.x = 0;
% Pseudolite{1}.y = x;
% Pseudolite{1}.z = height;
% 
% Pseudolite{2}.x = d;
% Pseudolite{2}.y = 0;
% Pseudolite{2}.z = height;
% 
% Pseudolite{3}.x = 2 * d;
% Pseudolite{3}.y = x;
% Pseudolite{3}.z = height;
% 
% Pseudolite{4}.x = d;
% Pseudolite{4}.y = 0.8 * x;
% Pseudolite{4}.z = height;

load([cd '\Functions\PseudoliteCorrdinates.mat']);

Pseudolite{1}.x = PseudoCoord.Rep(1).X;
Pseudolite{1}.y = PseudoCoord.Rep(1).Y;
Pseudolite{1}.z = PseudoCoord.Rep(1).Z;

Pseudolite{2}.x = PseudoCoord.Rep(2).X;
Pseudolite{2}.y = PseudoCoord.Rep(2).Y;
Pseudolite{2}.z = PseudoCoord.Rep(2).Z;

Pseudolite{3}.x = PseudoCoord.Rep(3).X;
Pseudolite{3}.y = PseudoCoord.Rep(3).Y;
Pseudolite{3}.z = PseudoCoord.Rep(3).Z;

Pseudolite{4}.x = PseudoCoord.Rep(4).X;
Pseudolite{4}.y = PseudoCoord.Rep(4).Y;
Pseudolite{4}.z = PseudoCoord.Rep(4).Z;

constellation = 1 : 32;

% ----- UserPosition -----------
UPos.z = PseudoCoord.UserPos.Z;%0;
gridValX = PseudoCoord.UserPos.X + (-50 : 10 : 50);
gridValY = PseudoCoord.UserPos.Y + (-50 : 10 : 50);%0 : 2 * x / 3 : 2 * x;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);

ps_size = size(Pseudolite);
psSizeCol = ps_size(2);

sizePoses = size(UPos.x);
constell = constellation(1 : ps_size(2));

err = zeros(size(UPos.x));

m = 1; 
parfor n = 1 : sizePoses(1) * sizePoses(2) % for each user location
    disp(n)
    curr_u_pos = [UPos.x(n) UPos.y(n) UPos.z];
    ranges_u_ps = FindRanges(Pseudolite, curr_u_pos);
                             
    time_propog = ranges_u_ps / c;
    
%     time_propog = [0.12184      0.12876      0.11936      0.13021];
    [filenames, rem_last_emp, posPeakOrig, ShiftZero, RealTimeOfPeak] ...
        ...
                       = SignalShaperGPS(time_propog, curr_u_pos, ...
                                         constell,...
                                         len_CA, sample_freq, bandwidth,...
                                         sig_dur, CN0(m), delta_f_doppl);
                                     
    %--------- Detector of the C/A signal ---------------------------------------------------
    [CA_code_pos_peak, byte_shift] = DetectorByMaxDoppl(filenames,...
                       ...
                       exp_num, constell, ShiftZero, sample_freq,...
                       quant_accum(m), threshold(m), len_CA);
                   
    %--------- Calculate PseudoRanges -------------------------------------
    [calculated_pseudo] = ErrorOfPseudorange(...
                ...
                        CA_code_pos_peak, byte_shift, ...
                        constell, time_propog, rem_last_emp, ...
                        ranges_u_ps, sample_freq, RealTimeOfPeak, len_CA);
    % --- Calculate user position ---------------
    sat_poses = [Pseudolite{1}.x Pseudolite{2}.x Pseudolite{3}.x Pseudolite{4}.x;   
                 Pseudolite{1}.y Pseudolite{2}.y Pseudolite{3}.y Pseudolite{4}.y;
                 Pseudolite{1}.z Pseudolite{2}.z Pseudolite{3}.z Pseudolite{4}.z];
    u_pos(n, :) = FindRecPosition(sat_poses, calculated_pseudo)
    err(n) = sqrt(sum((u_pos(n, :) - curr_u_pos) .^ 2))
    for k = 1:length(constell)
        delete(filenames{k});
    end
end