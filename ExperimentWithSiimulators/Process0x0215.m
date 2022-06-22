function res = Process0x0215(prms, Mes0x1502)
sizeStr = size(Mes0x1502);
sv_id = prms.sv_id;
glonass_id = 6;

svNum = length(sv_id);
tow = zeros(1, sizeStr(2));
ps_rng = zeros(sizeStr(2), svNum);
diffPsRngs = zeros(sizeStr(2), svNum);
doppl = zeros(sizeStr(2), svNum);
carr_phase = zeros(sizeStr(2), svNum);
raw_time = zeros(1, sizeStr(2));

posCnt = 0;
for n = 1 : sizeStr(2)
    svCnt = 0;
    SatsPoses = [];
    psRngs = [];
    RawData = Mes0x1502{n};
    raw_time(n) = RawData.rcvTow;
    if RawData.numMeas > 0
        [ProcessedMes, fourSatIsValid] = DataProcessor(RawData, ...
                                                       prms.ublox_gnss_id);
        necessarySat = CheckCANumsMatchUp(ProcessedMes.svId, ...
                                                        sv_id);
        if fourSatIsValid && necessarySat

            for k = 1 : length(ProcessedMes.svId)
                ind = (sv_id == ProcessedMes.svId(k));
                if sum(ind) && sum(ProcessedMes.trkStat{k}  - '0') >= 2

                    svCnt = svCnt + 1;
                    psRngs( ind) = ProcessedMes.prMes(k);
                    doppler(ind) = ProcessedMes.doMes(k);
                    carr_ph(ind) = ProcessedMes.cpMes(k); 
                end
            end
            inTimeShifts = (ProcessedMes.prMes - ProcessedMes.prMes(1)) / ...
                            prms.light_speed;
            posCnt = posCnt + 1;
            
            if(ProcessedMes.gnssId == prms.ublox_gnss_id)
                if(prms.ublox_gnss_id == prms.ublox_gnss.glonass)
                    gps_ls = 18;
                    glonass_ls = 0;

                    tod_gps = rem(ProcessedMes.rcvTow, 24 * 60 * 60); % - (gps_ls - glonass_ls);
                    utc_moscow = 3;
                    tod_glonass = tod_gps + utc_moscow * 60 * 60 ...
                                  - (gps_ls - glonass_ls);% + 1; ???? check in u-center
                    tow(posCnt) = tod_glonass;
                elseif prms.ublox_gnss_id == prms.ublox_gnss.beidou
                    tow(posCnt) = ProcessedMes.rcvTow - 14;
                else 
                    tow(posCnt) = ProcessedMes.rcvTow;
                end
                ps_rng(posCnt, 1 : length(psRngs)) = psRngs;
                diffPsRngs(posCnt, 1 : length(psRngs)) = psRngs - psRngs(1);
                doppl(posCnt, 1 : length(doppler)) = doppler;
                carr_phase(posCnt, 1 : length(carr_ph)) = carr_ph;
            end
        end
    end
end
res.tow           = tow(        1 : posCnt);
res.ps_rng        = ps_rng(     1 : posCnt, :);
res.diff_ps_rngs  = diffPsRngs( 1 : posCnt, :);
res.doppl_ubx     = doppl(      1 : posCnt, :);
res.carrier_phase = carr_phase( 1 : posCnt, :);

figure; plot(diff(raw_time));
figure; plot(tow(1 : posCnt -1), diff(tow(1 : posCnt)));
grid on;
title("TOW");
ylabel("TOW, sec");
end