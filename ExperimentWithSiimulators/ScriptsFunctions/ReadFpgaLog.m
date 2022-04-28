function [] = ReadFpgaLog(fullpath)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
sv_id =  [1     6    12    14    15    17    19    24    32];
svs_num = length(sv_id);
% A = importdata([folder filename]);
t = readtable(fullpath);
s = size(t);
tow = zeros(svs_num, ceil(s(1) / svs_num));
cnt_cell = zeros(1, svs_num);
for n = 1 : svs_num
    idx = find(t.sv_num == sv_id(n));
    if any(idx)
%         cnt_cell(idx) = cnt_cell(idx) + 1;
%         c(idx, cnt_cell(idx)) = t(n, :);
        tow(n, :) = t.tow(idx);
    end
end
end

