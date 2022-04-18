function [el, pr_res, poss_sv_id] = Process0x0135(Mes0x0135, tow) 
    struct_size = size(Mes0x0135);
    mess_num = struct_size(2);
    
    lengths = [length(tow), mess_num];
    len = min(lengths);
    
    poss_sv_id = [9 8 11 12 13 14  18 20 22]; % possible numbers
    el = zeros(mess_num, length(poss_sv_id));
    pr_res = zeros(mess_num, length(poss_sv_id));
    
    for k = 1 : mess_num 
        Mes = Mes0x0135{k};
        if ~isempty(Mes)
            t(k) = Mes.tow;
            used_in_nav(k) = 0;
            for n = 1 : Mes.num_svs
                % Used svs in navigation
                flags = Mes.flags{n};
                bin_view = dec2bin(flags(1)) - '0';
                if bitget(flags(1), 4, 'uint8')
                    used_in_nav(k) = used_in_nav(k) + 1;
                end
                % Check elevation
                if Mes.gnss_id == 0
                    ind = find(poss_sv_id == Mes.sv_id(n));
                    if any(ind)
                        el(k, ind) = Mes.elev(n);
                        pr_res(k, ind) = Mes.pr_res(n);
                    end
                end
            end
        end
    end
    plot(tow(1 : len), used_in_nav(1 : len));
    grid on;
    title("Svs number used in navigation");
end