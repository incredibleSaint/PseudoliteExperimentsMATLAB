% Модель, имитирующая расчет позиции пользователя в разных точках
% при использовании ЛНС.
clear;
close all;
addpath('Functions')

cd ..
addpath('Common');
cd GPS_Pseudolites_Model

tic;
% -- Parameters ----
CN0  = [55 50 ];%45 40 35];% 42 35 30 40 35];% dB-Hz 

threshold = [12 12 11 7 4];
%-------------------
samples_num = 10;

quant_accum = 5;

sig_dur = 4; % sec

sample_freq = 2;

delta_f_doppl = 0;

% -- Constants -----
NUM_CA_PER_BIT = 20;
c = 2.99792458e8;
len_CA = 1023;
t_CA = 1e-3;
f_CA = len_CA / t_CA;
bandwidth = 2 * len_CA * 1000;
%===========================

[Pseudolite, UPos, topology] = GetTopology();
[idxVisib, cntVisib] = NearFarEffect(Pseudolite, UPos);

constellation = 1 : 32;
ps_size = size(Pseudolite);
psSizeCol = ps_size(2);

sizePoses = size(UPos.x);
constell = constellation(1 : ps_size(2));
sv_num = length(constell);
sv_num = 16;

Res = cell(1, sv_num);
err = zeros(size(UPos.x));
err_cn0 = cell(size(UPos.x));
err_xy_cn0 = cell(size(UPos.x));

angles = zeros(1, sig_dur / t_CA + NUM_CA_PER_BIT);

cnt_err_peaks = [];

poses_num = sizePoses(1) * sizePoses(2);

pos_peak_orig = zeros(sv_num, poses_num);
pos_peak = zeros(sv_num, poses_num);

Errs = struct(  'err3D',      zeros(length(CN0), samples_num),    ...
                'err2D',      zeros(length(CN0), samples_num)     ...
                );

Params = struct(                                       ...
                'UsrCrdsTrue',     UPos,        ...
                'PseudolitePoses', {Pseudolite},       ...
                'CN0_dB_Hz',       CN0,                ...
                'srch_thrld',      threshold,          ...
                'sig_dur_sec',     sig_dur,            ...
                'smpl_freq_hz',    bandwidth,          ...
                'topology',        topology,           ...
                'sample_size',     samples_num         );


Res = cell(size(UPos.x));

for n = 1 : poses_num % for each user location
    vis_arr = idxVisib{n};% сделать функцию, которая находит теперь ближайшие 16 и уже по ним считать
    sv_id = find(vis_arr == 1);
    sv_num = length(sv_id);
    
    if sv_num < 4
        fprintf('%Point d: Less than 4 pseudolites \n \n', n);
        continue;
    end
    
    sat_poses = zeros(3, sv_num); 
    % Сохраним координаты спутников, которые видны в данной точке:
    for k = 1 : sv_num
       sat_poses(:, k) = [Pseudolite{sv_id(k)}.x Pseudolite{sv_id(k)}.y...
                          Pseudolite{sv_id(k)}.z];
    end
    
    curr_u_pos = [UPos.x(n) UPos.y(n) UPos.z];
    
    u_pos = zeros(poses_num, 3);
    ranges_u_ps = sqrt(sum((sat_poses - curr_u_pos') .^ 2));
    time_propog = ranges_u_ps / c; 
    
    % Find nearest pseudolites:
    if sv_num > 16
        sv_num = 16;
        [~, idx] = sort(ranges_u_ps);
        sv_id = idx(1 : sv_num);
        sat_poses = zeros(3, sv_num);
        for k = 1 : sv_num
            sat_poses(:, k) = [Pseudolite{idx(k)}.x Pseudolite{idx(k)}.y...
                          Pseudolite{idx(k)}.z];
        end
        ranges_u_ps = sqrt(sum((sat_poses - curr_u_pos') .^ 2));
        time_propog = ranges_u_ps / c;
    end
    
    err_samples = zeros(1 , samples_num);
    err_samples_xy = zeros(1, samples_num);
    err_ranges = zeros(sv_num, samples_num);

    curr_err_cn0 = zeros(length(CN0), samples_num);
    curr_err_xy_cn0   = zeros(length(CN0), samples_num);
    curr_err_rng_cn0 = cell(1, length(CN0));
    for m = 1 : length(CN0)

        for k = 1 : samples_num
            %--------- Detector of the C/A signal -----------------------------
            time_delays_calc = zeros(1, sv_num);
            
            rem_last_emp = zeros(1, sv_num);
            parfor f = 1 : sv_num
                [fname, temp, pos_peak_first] ...
                ...
                       = SignalShaperGPS(f, time_propog, ranges_u_ps, ...
                                         sat_poses, curr_u_pos, ...
                                         sv_id, f_CA,...
                                         len_CA, sample_freq, bandwidth,...
                                         sig_dur, CN0(m), delta_f_doppl);
                rem_last_emp(f) = temp;
                MainParams = struct(                    ...
                    'sv_id',        sv_id(f),    ...
                    'fname',        fname,          ...
                    'search_thrd',  threshold(m)    ...
                );
                % Tracking:
                Receiver = MainExp(MainParams);
                delete(fname);

                delay_chip = Receiver.Search.SamplesShifts;

                exp_phase = angle(Receiver.Track.CorVals{1});

                rem_pos = exp_phase(end - 200) / (2 * pi);
                pos = delay_chip + rem_pos;
                if abs(pos - pos_peak_first) > 0.5
                   pos = pos - 1;
%                    cnt_err_peaks(end + 1) = m;
                end
                if abs(pos - pos_peak_first) > 0.5
                   pos = pos + 2; 
                end
                if abs(pos - pos_peak_first) > 0.5
                   pos = pos - 1;
                end

                time_delays_calc(f) = pos / (f_CA * sample_freq);
            end
            % --- Calculate user position ---------------

            u_pos(n, :) = FindRecPosition(sat_poses, time_delays_calc * c);
            err_samples(k) = sqrt(sum((u_pos(n, :) - curr_u_pos) .^ 2));
            err_samples_xy(k) = sqrt(sum((u_pos(n, 1:2) - ...
                                                 curr_u_pos(1 : 2)) .^ 2));
            err_ranges(: , k) = ranges_u_ps - time_delays_calc * c;
        end
        
        curr_err_cn0(   m, :) = err_samples;
        curr_err_xy_cn0(m, :) = err_samples_xy;
        curr_err_rng_cn0{m} = err_ranges;
    end
    err_cn0{n} = curr_err_cn0;
    err_xy_cn0{n} = curr_err_xy_cn0;
    
    Errs.err3D = curr_err_cn0;
    Errs.err2D = curr_err_xy_cn0;
    Errs.err_psrng = curr_err_rng_cn0;
    Errs.sv_id = sv_id;
    Errs.sv_num = sv_num;
    
    Res{n} = Errs;
    Data = struct('Params', Params, 'Errs', {Res});
    save('Results\Res.mat', 'Data');
end
toc