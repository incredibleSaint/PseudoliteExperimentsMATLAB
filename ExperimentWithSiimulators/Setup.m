function prms = Setup()
gnss = 'bds';
% Ublox Gnss id:
% 0 - gps
% 1 - sbas
% 2 - galileo
% 3 - beidou
% 6 - glonass
ublox_gnss.gps    = 0;
ublox_gnss.beidou = 3;
ublox_gnss.glonass= 6;
prms.ublox_gnss = ublox_gnss;

if gnss == 'gps' 
    gnss_id = 0;
elseif gnss == 'bds'
    gnss_id = 3;
end
prms.ublox_gnss_id = gnss_id;

% ARM gnss id
% GNSS_NONE       = -1,
% GLONASS         = 0,
% GPS             = 1,
% GALILEO         = 2,
% BEIDOU          = 3,
% SBAS            = 4,
% SYSTEM_FIRST    = GLONASS,
% SYSTEM_COUNT    = 5, // rewrite this item if enum is extended
% GNSS_ERROR      = 6

if gnss == 'gps' 
    gnss_id = 1;
elseif gnss == 'bds'
    gnss_id = 3;
end
prms.fpga_gnss_id = gnss_id;

if prms.ublox_gnss_id == 0
    sv_id =  [1 6 12 14 15 17 19 24 32];
elseif prms.ublox_gnss_id == 3
    sv_id = [10 11 23 20 37 34 12 19];
elseif prms.ublox_gnss_id == 6
    sv_id = [13 22 12 4 21 3 14 23];
end
prms.sv_id = sv_id;
end