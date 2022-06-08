% clear;
% close all;
folderPath = [cd '/ScriptsFunctions'];
addpath(folderPath);
addpath([cd '/Records']);
%---------------------------------
%-- Parser of U-blox Messages: --%
% 
user = getenv('USERNAME');
folder = ['/home/' user '/Documents/'];
prms = Setup();

ubx_log = GetUbxLogFileName();

fpga_log = [ubx_log '.txt'];
ubx_log  = 'ALL_GNSS_ZED9_220317_092639';
% ubx_log = 'gps_real_6june2022';
% ubx_log = 'glonass_real_6june2022';

[t, time, sv_id_fpga, chs_num] = ReadFpgaLog(prms, [folder fpga_log]);
draw_log_fpga = 0;
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

fullName = [folder ubx_log '.ubx'];

[Mes0x0101, Mes0x0102, Mes0x1502, Mes0x0135] = ParserUbxpacket(fullName);

true_position = [2758750.0, 1617300.0, 5500165.0]; % STC 
all_gnss_file_position = [2758739.4, 1617299.2, 5500156.14];
true_position = all_gnss_file_position;
% true_position = [2758762.10206624 1617141.40083576 5500196.86403367]; % Misha


x_min_val = (start_time  -  60 * 10 ) * 1e3;
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

sizeStr = size(Mes0x1502);
load([cd '/ScriptsFunctions/PseudoliteCorrdinates.mat']);
c = 299792458;

posCnt = 0;
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
%========================
glonass_id = 6;
PseudoCoord.svId = sv_id_fpga;
svNum = length(PseudoCoord.svId);
tow = zeros(1, sizeStr(2));
ps_rng = zeros(sizeStr(2), svNum);
diffPsRngs = zeros(sizeStr(2), svNum);
doppl_ubx = zeros(sizeStr(2), svNum);
raw_time = zeros(1, sizeStr(2));

for n = 1 : sizeStr(2)
    svCnt = 0;
    SatsPoses = [];
    psRngs = [];
    
    if (posCnt == 97) 
        a  = 1;
    end

    RawData = Mes0x1502{n};
    raw_time(n) = RawData.rcvTow;
    
    if RawData.numMeas > 0
        [ProcessedMes, fourSatIsValid] = DataProcessor(RawData, ...
                                                       prms.ublox_gnss_id);
        necessarySat = CheckCANumsMatchUp(ProcessedMes.svId, ...
                                                        PseudoCoord.svId);
        if flagWorkWithSomeCAcodesJustPsRngs % when less than 4 CA-codes
            fourSatIsValid = 1;
            necessarySat = 1;
        end
        if fourSatIsValid && necessarySat

            for k = 1 : length(ProcessedMes.svId)
                ind = (PseudoCoord.svId == ProcessedMes.svId(k));
                if sum(ind) && sum(ProcessedMes.trkStat{k}  - '0') >= 2

                    svCnt = svCnt + 1;
                    if ~flagWorkWithSomeCAcodesJustPsRngs
%                         SatsPoses(1, ind) = PseudoCoord.Rep(ind).X;
%                         SatsPoses(2, ind) = PseudoCoord.Rep(ind).Y;
%                         SatsPoses(3, ind) = PseudoCoord.Rep(ind).Z;
                    end
                    psRngs(ind) = ProcessedMes.prMes(k);
                    doppler(ind) = ProcessedMes.doMes(k);
                end
            end

%             if ~flagWorkWithSomeCAcodesJustPsRngs
%                 if isempty(SatsPoses)
%                     continue
%                 end
%             end
            inTimeShifts = (ProcessedMes.prMes - ProcessedMes.prMes(1)) / c;

            if ~flagWorkWithSomeCAcodesJustPsRngs
%                 [UPos, err] = FindRecPosition(SatsPoses, psRngs);
%                 UserPoses(posCnt, :) = UPos;
%                 errPos3D(posCnt, :) = err;
            end
            posCnt = posCnt + 1;
            if posCnt == 500 
                a = 1;
%                 curr_theor_01ns = [800948551 799688193  722718258
%                 827920047 829444202 728981469 691569373 677257785 804165966];
%                 ps_rng_theor = curr_theor_01ns / 1e10 * 3e8
%                 ps_rng_theor - ps_rng_theor(1) - (psRngs - psRngs(1))
%                 ans = [ 0         -33.4616240784526
%                 -1630.63952538371          60.2115170620382          561.940843828022         -2272.69398476928          593.911151405424         -1494.46435207129          -2569.8585446775]
            end
            
            if(ProcessedMes.gnssId == prms.ublox_gnss_id)
                if(prms.ublox_gnss_id == glonass_id)
                    gps_ls = 18;
                    glonass_ls = 0;
    %                 ProcessedMes.rcvTow = 380137; % glonass tod = 45319
                    tod_gps = rem(ProcessedMes.rcvTow, 24 * 60 * 60); % - (gps_ls - glonass_ls);
                    utc_moscow = 3;
                    tod_glonass = tod_gps + utc_moscow * 60 * 60 - (gps_ls - glonass_ls);% + 1; ???? check in u-center
                    tow(posCnt) = tod_glonass;
% %             else
% %                 tow(posCnt) = ProcessedMes.rcvTow;
% %             end
%             ps_rng(posCnt, 1 : length(psRngs)) = psRngs;
%             diffPsRngs(posCnt, 1 : length(psRngs)) = psRngs - psRngs(1);
%             doppl_ubx(posCnt, 1 : length(doppler)) = doppler;
                elseif prms.ublox_gnss_id == prms.ublox_gnss.beidou
                    tow(posCnt) = ProcessedMes.rcvTow - 14;
                else 
                    tow(posCnt) = ProcessedMes.rcvTow;
                end
                ps_rng(posCnt, 1 : length(psRngs)) = psRngs;
                diffPsRngs(posCnt, 1 : length(psRngs)) = psRngs - psRngs(1);
                doppl_ubx(posCnt, 1 : length(doppler)) = doppler;
%                 end
            end
        end
    end
end
%%
figure; plot(diff(raw_time));
CompareUbloxAndFpgaPseudoranges(sv_id_fpga, t, tow, ps_rng, ...
                                doppl_ubx, x_min_val, x_max_val, prms);

isDraw = 1;
if isDraw
figure; plot(tow(1 : posCnt -1), diff(tow(1 : posCnt)));
grid on;
title("TOW");
ylabel("TOW, sec");

if ~flagWorkWithSomeCAcodesJustPsRngs
%     figure; plot(errPos3D(1 : posCnt));
%     ylabel("3D Error, met");
end
%%
for i = 1 : svNum
    legend_text{i} = num2str(PseudoCoord.svId(i));
end
% figure; plot(tow(1 : posCnt), diffPsRngs(1 : posCnt, :));
% ylabel("diffPsRngs, m");
% grid on;
% legend_text = cell(1, svNum);

% leg = legend(legend_text);
% title(leg, 'Номер псевдолита');

% -- Plot Error of pseudorange difference --------
is_draw_psr_error = 0;
if is_draw_psr_error 
    figErr = figure;
    emitted_rng_diff = 0 : 1000 : 0;
    plot(diffPsRngs(1 : posCnt, :));% - emitted_rng_diff);
    xlabel("t, сек");
    ylabel('{\Delta}R, м');
    grid on;
    leg = legend(legend_text);
    title(leg, 'Номер псевдолита');
    leg.NumColumnsMode = 'manual';
    led.NumColumns = 2;
end
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
end
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