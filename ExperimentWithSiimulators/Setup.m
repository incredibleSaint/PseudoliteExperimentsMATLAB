function prms = Setup()
prms.gnss_id = [0];

if prms.gnss_id == 0 
    sv_id =  [1 6 12 14 15 17 19 24 32];
elseif prms.gnss_id == 3
    sv_id = [10 11 23 20 37 34 12 19];
elseif prms.gnss_id == 6
    sv_id = [13 22 12 4 21 3 14 23];
end
prms.sv_id = sv_id;
end