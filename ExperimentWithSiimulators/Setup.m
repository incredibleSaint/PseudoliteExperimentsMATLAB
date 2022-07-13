function prms = Setup()
gnss = 'gps';
prms.current_gnss = gnss;
% Ublox Gnss id:
% 0 - gps
% 1 - sbas
% 2 - galileo
% 3 - beidou
% 6 - glonass
ublox_gnss.beidou  = 3;
ublox_gnss.galileo = 2;
ublox_gnss.glonass = 6;
ublox_gnss.gps     = 0;
prms.ublox_gnss = ublox_gnss;

if gnss == 'gps' 
    gnss_id = ublox_gnss.gps;
elseif gnss == 'bds'
    gnss_id = ublox_gnss.beidou;
elseif gnss == 'gln'
    gnss_id = ublox_gnss.glonass;
elseif gnss == 'gal'
    gnss_id = ublox_gnss.galileo;
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
elseif gnss == 'gln'
    gnss_id = 0;
elseif gnss == 'gal'
    gnss_id = 2;
end
prms.fpga_gnss_id = gnss_id;

if gnss == 'gps'
    sv_id =  [1 6 12 14 15 17 19 24 32];
%     sv_id = [23 27 18 16 10 15 13 8 26 7];
elseif gnss == 'bds'
    sv_id = [10 11 23 20 37 34 12 19];
elseif gnss == 'gln'
%     sv_id = [13 22 12 4 21 3 14 23];
    sv_id = [13 22 12 4 14 23 21 5];
elseif gnss == 'gal'
    sv_id = [27 14 19 34 21 30 15 36 4];
end
prms.sv_id = sv_id;
prms.ref_channel = 4;

prms.glonass.litera = [1, -4, 5, 6, 1, -4, 5, 6, -2, -7, 0, -1, -2, -7, 0, -1, 4, -3, 3, 2, 4, -3, 3, 2];

prms.light_speed = 299792458;
end