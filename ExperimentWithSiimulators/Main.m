clear;
close all;
USE_GUI = 0; % true - choose file with GUI

ANALYZED_GNSS = 'bds'; % gps - GPS, gln - GLONASS, gal - GALILEO, bds - BEIDOU

% todo добавить режим - просто нарисовать результат юблокс лога
%% ====== Modes =========
% Choose only one mode (if several modes is used => 
%                                                script is using first true)
% 0. Plot ubx
% 1. Plot figures for u-blox receiver gnss chip
modes.visualize_ublox_log = false;
% 2. Compare fpga log and u-blox data (pseudoranges, doppler, etc)
modes.compare_ublox_and_fpga = false;
% 3. Compare two u-blox files:
modes.compare_ublox_files = false;
% 4. Compare two fpga files:
modes.compare_fpga_files = true;


addpath(fullfile(cd, 'ScriptsFunctions'));
addpath(fullfile(cd, 'Records'));

modes = CheckForOnlyOneMode(modes);
%-------------------------------------------------
%-- Parser of U-blox Messages: --%

prms = Setup(ANALYZED_GNSS);

if USE_GUI
    if modes.compare_ublox_and_fpga
        [fpga_log, fpga_folder] = uigetfile({'*.txt'}, 'Choose fpga log file'); 
        [ubx_log, ubx_folder] = uigetfile({'*.ubx'}, 'Choose u-blox receiver log file');
        fullName = fullfile(ubx_folder, ubx_log);
    end
    if modes.compare_ublox_files
        [ubx_log, ubx_folder] = uigetfile({'*.ubx'}, 'Choose first u-blox receiver log file');
        fullName = fullfile(ubx_folder, ubx_log);
        [second_file, second_folder] = uigetfile({'*.ubx'}, 'Choose second u-blox receiver  log file');
        second_path = fullfile(second_folder, second_file);
    end
    if modes.compare_fpga_files
        [fpga_file1, fpga_path1] = uigetfile({'*.txt'}, 'Choose first fpga log file');
        fpga_log1 = fullfile(fpga_path1, fpga_file1);
        [fpga_file1, fpga_path2] = uigetfile({'*.txt'}, 'Choose second fpga log file'); 
        fpga_log2 = fullfile(fpga_path1, fpga_file1);
    end
else
    user = getenv('USERNAME');
    folder = ['/home/' user '/Documents/'];  % this folder should containt files, if USE_GUI = false;
    ubx_log = GetUbxLogFileName();
    
    ubx_log  = 'zedf9t_gps_gln_bds_3d_long';%'gps_bds_gln_1200m_long';%'matalb';% 'saved_almanac_0108'; %'ALL_GNSS_ZED9_220317_092639';
   
    fullName = fullfile(folder, [ubx_log '.ubx']); 
    fpga_log = [ubx_log '.txt'];
    fpga_folder = folder;
    if modes.compare_ublox_and_fpga
        fpga_log= 'gal_calc_plus_1sec_v2.txt'; 
        ubx_log = 'gal_calc_plus_1sec_v2.ubx';
        fullName = fullfile(folder, ubx_log);
    end
    if modes.compare_fpga_files
        fpga_file1 = 'all_gnss_bits_delay_0.txt';%'ALL_GNSS_delay_0.txt';%'ALL_GNSS_delay_bits_not_zero.txt';% 'Gps_with_delay_not_virt_GetNextBs.txt';% 'ubx_file_0108';%'gln_ch_0_1_2_turned_off_v3';% 'fpga_522062003';
        fpga_file2 = 'all_gnss_bits_delay_not_zero.txt';%'ALL_GNSS_delay_isnot_0_except_galileo.txt';%'ALL_GNSS_zero_bits_delay_common_GetNextBs.txt';%'GPS_without_delay_virt_GetNextBitstream.txt';%'saved_almanac_0108';% 'gln_ch_0_1_2_turned_off_v2';% 'fpga_522062401';
        fpga_log1 = fullfile(folder, fpga_file1);
        fpga_log2 = fullfile(folder, fpga_file2);
        prms.fpga_logs{1} = fpga_log1;
        prms.fpga_logs{2} = fpga_log2;
    end
    if modes.compare_ublox_files
        ubx_file1 = ['ublox_gps.ubx'];% ['gal_calc_plus_1sec_v2.ubx']; %['gal_calc_plus_1sec_v2.ubx'];% ['gal_calc_plus_1sec.ubx']; %['gal_3d_fix_6ch' '.ubx'];
        ubx_file2 = ['rinex_gps_v2.ubx'];% ['ALL_GNSS_ZED9_220317_092639' '.ubx'];
        fullName = fullfile(folder, ubx_file1);
        second_path = fullfile(folder, ubx_file2);
    end
end

if modes.compare_fpga_files
    [t1, time1, sv_id_fpga1, chs_num1] = ReadFpgaLog(prms, fpga_log1);
    [t2, time2, sv_id_fpga2, chs_num2] = ReadFpgaLog(prms, fpga_log2);

    CompareFpgaLogFiles(t1, t2, time1, time2, prms);
end


if modes.compare_ublox_and_fpga
    draw_log_fpga = 0;
    fprintf('Compare u-blox log and fpga log\n');
    [t, time, sv_id_fpga, chs_num] = ReadFpgaLog(prms, [fpga_folder fpga_log]);
    
    
    
    if draw_log_fpga
        figure; plot(diff(time));
        for n = 1 : length(sv_id_fpga)
            idx = find(t.sv_num == sv_id_fpga(n));
            curr_del_calc = t.curr_delay_calc(idx);
            curr_clk_cnt  = t.curr_clk_count( idx);
            tow = t.tow(idx);
           
            bits_delay = floor(curr_del_calc(idx(1)) / 1e10 / 20e-3);
            fpga_delay_sec = bits_delay * 20e-3 + curr_clk_cnt / 250e6;
            diff_secs = fpga_delay_sec - curr_del_calc / 1e10;
            figure;
            subplot(2, 1, 1)
            plot(tow, diff_secs * 3e8);
            grid on;
            xlim([min(time(2 : end)) max(time)]);
            
            sv_str = num2str(t.sv_num(idx(1)));
            ch_str = num2str(t.ch_num(idx(1)));
            title([ 'Channel = ' ch_str ' ' 'Sv num = '  sv_str]);
            ylabel("error(R), met");
            xlabel("TOW, sec");
            ylim([-2 2]);
        
            subplot(2, 1, 2);
            plot(tow, floor(curr_del_calc / 1e10 / 20e-3))
            ylabel("Delay in navmess bits");
            xlabel("TOW, sec");
            grid on;
        
    %         subplot(3, 1, 3);
    %         plot(tow(2 : end), diff(curr_del_calc) / 1e10 * 3e8);
    %         grid on;
        end
        figure;
        plot(t.curr_clk_count(10 : 12 : end) / 250e6);
        title("Channel for diff(f_fpga - f_arm");
    end   
    
    % Draw elevations and residuals of satellites, used in navigation:
    draw_elev_res = 0;
    % Start time in *.ubx file. GNSS time of week (seconds)
    start_time = 379900;
    % Limit for plot (minutes)
    mins = 90;
    
    
    
    [Mes0x0101, Mes0x0102, Mes0x1502, Mes0x0135] = ParserUbxpacket(fullName);
    
    true_position = [2758750.0, 1617300.0, 5500165.0]; % STC 
    all_gnss_file_position = [2758739.4, 1617299.2, 5500156.14];
    true_position = true_position;%all_gnss_file_position;
    % true_position = [2758762.10206624 1617141.40083576 5500196.86403367]; % Misha
    
    
    x_min_val = (start_time - 60 * 10 ) * 1e3;
    x_max_val = (start_time + 60 * mins) * 1e3;
    y_min_val = 0;
    y_max_val = 20;
    
    % glonass real
    % x_max_val = (145838 + 30 * 60)*1e3;
    % x_min_val = (145258 ) * 1e3; 
    
    figure;
    title(ubx_log);
    subplot(5, 1, 1);
    [err_3D, t0101, x, y, z] = Process0x0101(Mes0x0101, true_position, ubx_log, ...
                                             x_min_val, x_max_val);

    subplot(5, 1, 2);
    [h_error, t0102] = Process0x0102(Mes0x0102, true_position, ubx_log, x_min_val, x_max_val);
    
    subplot(5, 1, 3);
    HorizontalError(err_3D, h_error, t0101, t0102, ubx_log, ...
                    x_min_val, x_max_val);
    subplot(5, 1, 4);
    [el, pr_res, t0135, sv_id] = Process0x0135(Mes0x0135, x_min_val, x_max_val);
    
    subplot(5, 1, 5);
    PlotCoordsError(t0101, x, y, z, true_position, x_min_val, x_max_val);
    
    if draw_elev_res
        PlotElevationAndResidual(sv_id_fpga, t0135, el, pr_res, ubx_log, ...
                             x_min_val, x_max_val);
    end
    
    % sizeStr = size(Mes0x1502);
    load([cd '/ScriptsFunctions/PseudoliteCorrdinates.mat']);
    
    
    
    % ==  Check pseudorange for some CAcodes (without positioning) ======
    flagWorkWithSomeCAcodesJustPsRngs = 0;
    if flagWorkWithSomeCAcodesJustPsRngs
        size_debug_file = size('ReferenceForDebugSimulation_COM53_210702_151500.ubx');
        if(size_debug_file(2) == size(ubx_log))
            if(ubx_log == 'ReferenceForDebugSimulation_COM53_210702_151500.ubx') 
                PseudoCoord.svId =[10 22 1 21 32 3];
            end
        end
    end
    
    ubx_raw_measure = Process0x0215(prms, Mes0x1502);
    
    CompareUbloxAndFpgaPseudoranges(sv_id_fpga, t, ubx_raw_measure, x_min_val, x_max_val, prms);
end

if modes.compare_ublox_files
    fprintf('Compare u-blox files with each other\n');
    if ~USE_GUI
%         second_file = 'ubx_file_0108';% 'ALL_GNSS_ZED9_220317_092639';
    %     second_file = 'glnl_eph_utc_time';
%         second_path = [folder second_file '.ubx'];
    end
    [~, ~, Mes0x1502, ~] = ParserUbxpacket(second_path);
    ubx_raw_measure1 = Process0x0215(prms, Mes0x1502);

    [~, ~, Mes0x1502, ~] = ParserUbxpacket(fullName);
    ubx_raw_measure2 = Process0x0215(prms, Mes0x1502);

    CompareUbloxFiles(prms, ubx_raw_measure1, ubx_raw_measure2);
end

%%
% for i = 1 : svNum
%     legend_text{i} = num2str(PseudoCoord.svId(i));
% end
% figure; plot(tow(1 : posCnt), diffPsRngs(1 : posCnt, :));
% ylabel("diffPsRngs, m");
% grid on;
% legend_text = cell(1, svNum);

% leg = legend(legend_text);
% title(leg, 'Номер псевдолита');

% -- Plot Error of pseudorange difference --------
% is_draw_psr_error = 0;
% if is_draw_psr_error 
%     figErr = figure;
%     emitted_rng_diff = 0 : 1000 : 0;
%     plot(diffPsRngs(1 : posCnt, :));% - emitted_rng_diff);
%     xlabel("t, сек");
%     ylabel('{\Delta}R, м');
%     grid on;
%     leg = legend(legend_text);
%     title(leg, 'Номер псевдолита');
%     leg.NumColumnsMode = 'manual';
%     led.NumColumns = 2;
% end
% --- Plot speed of changing difference pseudoranges (Ublox) ------
% speed_ubx_ps_rng = diff(ps_rng(1 : posCnt, :));
% figure; plot(tow(1 : posCnt -1), speed_ubx_ps_rng);
% title("diff(psR_{ubx}), m");
% xlabel('t, сек');
% ylabel('speed diff(R), м/c');
% grid on; ylim([-2e3 1e3]);
% leg = legend(legend_text);
% title(leg, 'CA number');
% leg.NumColumnsMode = 'manual';
% led.NumColumns = 2;
% cd 'Results'
% saveas(figErr, [fileName '.emf']);
% cd ..

% figure; plot(diffPsRngs - mean(diffPsRngs))
% legend(num2str(mean(diffPsRngs)'));
% refDiffPs = [0 : 200 : 600];
% for n = 1 : 4
%    maxDiff = max(diffPsRngs(:, n)); 
%    minDiff = min(diffPsRngs(:, n));
%    
%    changesDueTime(n) = maxDiff - minDiff;
%    
%    meanDiff(n) = mean(diffPsRngs(:, n));
%    
%    
% end
% ppsErrorExp = meanDiff - refDiffPs;
% 
% stdPps = 250e-9;
% 
% stdPpsInMet = c * stdPps;
% if stdPpsInMet - abs(ppsErrorExp) > 0 
%    fprintf("Errors of pseudoranges satisfy 1PPS errors \n"); 
% end
% end
% disp ("Ublox Diff PsRnges ");
% diffPsRngs(20, :) - diffPsRngs(20, 1)
% 
% xlabel('t, сек')
% ylabel('3D error, м')
% grid on;

%% Diff between ARM and Ublox
% TOW = 486937;%487108;
% idx = find(round(tow) == TOW);
% %-- TOW = 486973 -------
% fpga_del = [702359320  672934480 704034960 746439360] / 1e10 * 2.99792458e8;
% 
% d_fpga = [-274.53 -128.52 160.56 -588.54];
% d_fpga = [-282.81 -142.11 151.14 -595.23];
% err_ubx = diffPsRngs(idx, :) -diffPsRngs(idx, 1) - ( fpga_del - fpga_del(1)) %- (d_fpga - d_fpga(1));% * (-0.06);
% %----TOW = 486937 ----------------------
% fpga_del = [702700440  673107880 703855560 747155040] / 1e10 * 2.99792458e8;
% 
% d_fpga = [-285.63 -146.76 147.9 -597.48];
% err_ubx = diffPsRngs(idx, :) -diffPsRngs(idx, 1) - ( fpga_del - fpga_del(1)) - (d_fpga - d_fpga(1)) * (-0.06);
% % ---------------------------Second record------------------------------
% fpga_del = [702700400 673107920 703855560 747155040] / 1e10 * 2.99792458e8;
% err_ubx = diffPsRngs(idx, :) -diffPsRngs(idx, 1) - ( fpga_del - fpga_del(1)) - (d_fpga - d_fpga(1)) * (0)
% %=== find diffPsRng for given TOW: ===
% 
% 
% % diff_arm = [-273 -123 163.2 277.2 -588];
% diff_arm = [-27.6 228 354 -537.6 -274.8];
% fprintf("Arm diff = "); fprintf("%d ", diff_arm - diff_arm(1));
% 
% 
% % idx = idx + 50;
% fprintf("\nUblox:\nTOW = %d\n", tow(idx(1))); 
% fprintf( "diffPsRngs = %d\n", ...
%                                                 diffPsRngs(idx(1), :));
% delta_calc = round(tow(idx)) - tow(idx);
% d_psR_err = speed_diffPsRngs(idx, :) * (delta_calc - 7);
% 
% 
% % psRng_arm = [816175360 701092200 672325680 704752960 717769800 743740920]
% % / 1e10 * 3e8; % 107
% % psRng_arm = [701083160 672321560 704758360 717779080 743721400] / 1e10 * 3e8; % 108
% % psRng_arm = [670463040 709531600 725498720 730029360 765041400] / 1e10 * 3e8;
% fprintf("ARM:\n"); fprintf("diffPsRngs = %d\n", psRng_arm - psRng_arm(1));
% fprintf("double diff: ");
% disp(diffPsRngs(idx(1), :) - ((psRng_arm - psRng_arm(1)) - d_psR_err));
% 
% vvv = [150 200 250 300 350];
% ch_num = 3 : 7;
% prev_a = zeros(1, 5);
% for i = 1 : 100
%     if i == 99 
%         b = 3;
%     end
%     a = prev_a + vvv + i * 0.1 * ch_num; 
%     prev_a = a;
% end
% fprintf("preva = %d, a = %d\n", prev_a, a);
% fprintf("delta = %d\n", a)