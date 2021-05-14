% Модель, имитирующая расчет позиции пользователя в разных точках
% при использовании ЛНС.
clear;
addpath('Functions')
tic;
% -- Parameters ----
CN0  = [80 42 35 30 40 35];% dB-Hz 

threshold = [0.95];

exp_num = 1;

quant_accum = 5;

sig_dur = 10; % sec

sample_freq = 4;

delta_f_doppl = 0;

samples_num = 1;
% -- Constants -----
NUM_CA_PER_BIT = 20;
c = 2.99792458e8;
len_CA = 1023;
t_CA = 1e-3;
f_CA = len_CA / t_CA;
bandwidth = 2 * len_CA * 1000;
%-------------------

%======== Rombus poses ===========
% d = 1000;
% x = d / tand(60);
% S = 1 / 2 * 2 * d * 2 * x;
% height = d * 1e-2;
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
% Pseudolite{4}.y = 2 * x;
% Pseudolite{4}.z = height + 30;
% % ----- UserPosition -----------
% UPos.z = 0;
% gridValX = d + 0 : 2 * d / 100 : 2 * d;
% gridValY = x + 0 : 2 * x / 100 : 2 * x;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);
% UPos.x = d;
% UPos.y = x;

% ======= End Rombus ===============

%======Random pseudolites positions (works) ===============================

% load([cd '\Functions\PseudoliteCorrdinates.mat']);
% 
% Pseudolite{1}.x = PseudoCoord.Rep(1).X;
% Pseudolite{1}.y = PseudoCoord.Rep(1).Y;
% Pseudolite{1}.z = PseudoCoord.Rep(1).Z;
% 
% Pseudolite{2}.x = PseudoCoord.Rep(2).X;
% Pseudolite{2}.y = PseudoCoord.Rep(2).Y;
% Pseudolite{2}.z = PseudoCoord.Rep(2).Z;
% 
% Pseudolite{3}.x = PseudoCoord.Rep(3).X;
% Pseudolite{3}.y = PseudoCoord.Rep(3).Y;
% Pseudolite{3}.z = PseudoCoord.Rep(3).Z;
% 
% Pseudolite{4}.x = PseudoCoord.Rep(4).X;
% Pseudolite{4}.y = PseudoCoord.Rep(4).Y;
% Pseudolite{4}.z = PseudoCoord.Rep(4).Z;
% 
% 
% 
% % ----- UserPosition -----------
% UPos.z = PseudoCoord.UserPos.Z;%0;
% gridValX = PseudoCoord.UserPos.X + (-50 : 10 : 50);
% gridValY = PseudoCoord.UserPos.Y + (-50 : 10 : 50);%0 : 2 * x / 3 : 2 * x;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);
%============= End random pseudolites ==============

% === Ideal GDOP (120 degrees)

r  = 200;
pr_x = r * sind(30);
pr_y = r * cosd(30);

height = 100;

height_zenith = 10 * height;

Pseudolite{1}.x = r;
Pseudolite{1}.y = 0;
Pseudolite{1}.z = height;

Pseudolite{2}.x = -pr_x;
Pseudolite{2}.y =  pr_y;
Pseudolite{2}.z = height;

Pseudolite{3}.x = -pr_x;
Pseudolite{3}.y = -pr_y;
Pseudolite{3}.z = height;

Pseudolite{4}.x = 0;
Pseudolite{4}.y = 0;
Pseudolite{4}.z = height_zenith;

%----- UserPosition -----------
UPos.z = 0;
gridValX = 5 : 5 : 100 ;
gridValY = 60 : 5 : 100 ;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);
%===========================

constellation = 1 : 32;
ps_size = size(Pseudolite);
psSizeCol = ps_size(2);

sizePoses = size(UPos.x);
constell = constellation(1 : ps_size(2));

Res = cell(1, length(constell));
err = zeros(size(UPos.x));

angles = zeros(length(constell), sig_dur / t_CA + NUM_CA_PER_BIT);

m = 1; 

for n = 1 : sizePoses(1) * sizePoses(2) % for each user location
    err_samples = zeros(1, samples_num);
    for k = 1 : samples_num

        disp(n)
        curr_u_pos = [UPos.x(n) UPos.y(n) UPos.z];
        ranges_u_ps = FindRanges(Pseudolite, curr_u_pos);

        time_propog = ranges_u_ps / c;

    %     time_propog = [0.12184      0.12876      0.11936      0.13021];
        [filenames, rem_last_emp, pos_peak_first] ...
            ...
                           = SignalShaperGPS(time_propog, curr_u_pos, ...
                                             constell, f_CA,...
                                             len_CA, sample_freq, bandwidth,...
                                             sig_dur, CN0(m), delta_f_doppl);

        %--------- Detector of the C/A signal -----------------------------
        for f = 1 : length(constell)
            Res{f} = MainExp(filenames{f}, constell(f));
            
            pos_peak(f) = Res{f}.Search.SamplesShifts - 1;
            
            exp_phase = angle(Res{f}.Track.CorVals{1});
            angles(f, 1 : length(exp_phase)) = exp_phase;
            rem_pos(f) = angles(f, 9500) / (2 * pi);
%             if rem_pos(f) < 0
%                rem_pos(f) = rem_pos(f) + 1; 
%             end
            pos_peak(f) = pos_peak(f) + rem_pos(f);
            time_delays_calc(f) = pos_peak(f) / (f_CA * sample_freq);
        end
%         [CA_code_pos_peak, byte_shift] = DetectorByMaxDoppl(filenames,...
%                            ...
%                            exp_num, constell, ShiftZero, sample_freq,...
%                            quant_accum(m), threshold(m), len_CA);

        %--------- Calculate PseudoRanges -------------------------------------
%         [calculated_pseudo] = ErrorOfPseudorange(...
%                     ...
%                             CA_code_pos_peak, byte_shift, ...
%                             constell, time_propog, rem_last_emp, ...
%                             ranges_u_ps, sample_freq, RealTimeOfPeak, len_CA);
        % --- Calculate user position ---------------
        sat_poses = [Pseudolite{1}.x Pseudolite{2}.x Pseudolite{3}.x Pseudolite{4}.x;   
                     Pseudolite{1}.y Pseudolite{2}.y Pseudolite{3}.y Pseudolite{4}.y;
                     Pseudolite{1}.z Pseudolite{2}.z Pseudolite{3}.z Pseudolite{4}.z];
        u_pos(n, :) = FindRecPosition(sat_poses, time_delays_calc * c);
        err_samples(k) = sqrt(sum((u_pos(n, :) - curr_u_pos) .^ 2));
        err_samples_xy(k) = sqrt(sum((u_pos(n, 1 : 2) - ...
                                                curr_u_pos(1 : 2)) .^ 2));
        for f = 1:length(constell)
            delete(filenames{f});
        end
        toc
    end
    err(n) = mean(err_samples)
    err_xy(n) = mean(err_samples_xy);
end