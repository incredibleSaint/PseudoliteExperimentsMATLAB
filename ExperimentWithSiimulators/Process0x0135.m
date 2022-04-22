function [el, pr_res, t, used_sv_id] = Process0x0135(Mes0x0135, ...
                                                  x_min_val, x_max_val) 
    struct_size = size(Mes0x0135);
    mess_num = struct_size(2);   
    poss_sv_id = [1 : 32];% [9 8 11 12 13 14 18 20 22]; % possible numbers
    used_sv_id = [];
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
                    if Mes.gnss_id == 0
                        ind = find(poss_sv_id == Mes.sv_id(n));
                        if any(ind)
                            ind_already = find(used_sv_id == Mes.sv_id(n));
                            if (~any(ind_already))
                                used_sv_id(length(used_sv_id) + 1) = Mes.sv_id(n);
                                ind_already = length(used_sv_id);
                            end
                        end
                    end
                end
                % Check elevation
                if Mes.gnss_id == 0 % 0 = gps  
                    ind_already = find(used_sv_id == Mes.sv_id(n));
                    if any(ind_already)
                        el(    k, ind_already) = Mes.elev(n);
                        pr_res(k, ind_already) = Mes.pr_res(n);
                    end
                end
            end
        end
    end
    ind = intersect(find(t >= x_min_val), find(t <= x_max_val));
    t           = t(ind);
    used_in_nav = used_in_nav(ind);
    el          = el(ind, :);
    pr_res      = pr_res(ind, :);

    plot(t, used_in_nav);
    grid on;
    title("Svs number used in navigation");
    xlim([x_min_val x_max_val]);
end