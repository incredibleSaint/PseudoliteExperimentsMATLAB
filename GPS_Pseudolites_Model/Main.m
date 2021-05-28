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
CN0  = [50 40 35];% 42 35 30 40 35];% dB-Hz 

threshold = [12 11 7 4];
%-------------------
samples_num = 20;

% exp_num = 1;


quant_accum = 5;

sig_dur = 6; % sec

sample_freq = 2;

delta_f_doppl = 0;

% -- Constants -----
NUM_CA_PER_BIT = 20;
c = 2.99792458e8;
len_CA = 1023;
t_CA = 1e-3;
f_CA = len_CA / t_CA;
bandwidth = 2 * len_CA * 1000;
%-------------------

[Pseudolite, UPos, topology] = GetTopology();

constellation = 1 : 32;
ps_size = size(Pseudolite);
psSizeCol = ps_size(2);

sizePoses = size(UPos.x);
constell = constellation(1 : ps_size(2));
sv_num = length(constell);

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
%                'UsrCrdsTrue',     zeros(1, 3),               ...
%                'PseudolitePoses', Pseudolite,         ...
%                'CN0_dB_Hz',       CN0,                ...
%                'srch_thrld',      threshold,          ...
%                'sig_dur_sec',     sig_dur,            ...
%                'smpl_freq_hz',    bandwidth,          ...
%                'topology',        topology,           ...
%                'sample_size',     samples_num         ...

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
    err_samples = zeros(1 , samples_num);
    err_samples_xy = zeros(1, samples_num);
    
    curr_u_pos = [UPos.x(n) UPos.y(n) UPos.z];
    
    sat_poses = [ Pseudolite{1}.x Pseudolite{2}.x Pseudolite{3}.x Pseudolite{4}.x;   
                  Pseudolite{1}.y Pseudolite{2}.y Pseudolite{3}.y Pseudolite{4}.y;
                  Pseudolite{1}.z Pseudolite{2}.z Pseudolite{3}.z Pseudolite{4}.z ];

    curr_err_cn0 = zeros(length(CN0), samples_num);
    curr_err_xy_cn0   = zeros(length(CN0), samples_num);
    for m = 1 : length(CN0)

        for k = 1 : samples_num
            disp(n)
            u_pos = zeros(poses_num, 3);

            ranges_u_ps = FindRanges(Pseudolite, curr_u_pos);
            time_propog = ranges_u_ps / c;        
            %--------- Detector of the C/A signal -----------------------------
            time_delays_calc = zeros(1, sv_num);
            
            rem_last_emp = zeros(1, sv_num);
            parfor f = 1 : sv_num
                [fname, temp, pos_peak_first] ...
                ...
                       = SignalShaperGPS(f, time_propog, ranges_u_ps, ...
                                         sat_poses, curr_u_pos, ...
                                         constell, f_CA,...
                                         len_CA, sample_freq, bandwidth,...
                                         sig_dur, CN0(m), delta_f_doppl);
                rem_last_emp(f) = temp;
                MainParams = struct(                    ...
                    'sv_id',        constell(f),    ...
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
%                 pos_peak(f, n) = pos;
                time_delays_calc(f) = pos / (f_CA * sample_freq);
            end
%             pos_peak_orig(:, n) = pos_peak_first;
            % --- Calculate user position ---------------

            u_pos(n, :) = FindRecPosition(sat_poses, time_delays_calc * c);
            err_samples(k) = sqrt(sum((u_pos(n, :) - curr_u_pos) .^ 2));
            err_samples_xy(k) = sqrt(sum((u_pos(n, 1:2) - ...
                                                 curr_u_pos(1 : 2)) .^ 2));

        end

%         err = mean(err_samples);
%         err_xy = mean(err_samples_xy);

        curr_err_cn0(   m, :) = err_samples;
        curr_err_xy_cn0(m, :) = err_samples_xy;

    end
    err_cn0{n} = curr_err_cn0;
    err_xy_cn0{n} = curr_err_xy_cn0;
    
    Errs.err3D = curr_err_cn0;
    Errs.err2D = curr_err_xy_cn0;
    
    Res{n} = Errs;
    Data = struct('Params', Params, 'Errs', {Res});
    save('Results\Res.mat', 'Data');
end
toc