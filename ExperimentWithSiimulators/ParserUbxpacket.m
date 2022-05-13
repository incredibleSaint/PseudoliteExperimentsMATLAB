function [Mes0x0101, Mes0x0102, Mes0x1502, Mes0x0135] ...
                                                    = ParserUbxpacket(full_name, varargin)
MAGIC0 = hex2dec('B5');
MAGIC1 = hex2dec('62');
temp = dir(full_name);
size_all = temp.bytes;
clear temp;
file = fopen(full_name, 'r');

portion     = 32 * 1024 * 1024;
packet_len  = 256*4;
portion_pack= portion + packet_len;
portCnt     = fix((size_all + portion - 1)/portion);
portPos     = 0;
cnt_out_data= 1;

tow = -1;
tow2 = -1;
% Init --------
cnt1502 = 0;
cnt0101 = 0;
cnt0102 = 0;
cnt0135 = 0;
Mes0x0102 = [];
if(file ~= -1)
    while(portPos < portCnt)
        fseek(file, portion * portPos, 'bof');
        size_rest = (size_all - portion * portPos);
        if(size_rest > portion_pack)
            size = portion_pack;
        else
            size = size_rest;
        end
        data = fread(file, size, 'uint8');

        h_len = 3 * 4;
        pos = 1;
        portPos = portPos + 1;

        cnt_el = 1;

        
        while(pos < (size - packet_len) && pos < 5 * 60 * 5000)
            if((data(pos) == MAGIC0) & (data(pos + 1) == MAGIC1))
                command = data(pos + 3) * 2^8 + data(pos + 2); % id | class
                length  = data(pos + 5) * 2^8 + data(pos + 4);

                switch (command)
                    case hex2dec('1502') % UBX-RXW-RAWX
                        cnt1502 = cnt1502 + 1;
                        pp     = pos + 6; % after header
                        rcvTowUInt8 = data(pp + (0 : 7));
                        Data.rcvTow = typecast(uint8(rcvTowUInt8), ...
                                                                 'double'); 
                        Data.week = data(pp + 9) * 2 ^ 8 + ...
                                                  data(pp + 8) * 2 ^ 0;
                        Data.leapS = typecast(uint8(data(pp + 10)), ... 
                                                               'int8');
                        numMeas = data(pp + 11);
                        Data.numMeas = numMeas;
                        Data.recStat = data(pp + 12);
                        Data.reserved = dec2bin(data(pp + 1));
                        for k = 1 : numMeas
                            psRngInt8 = ...
                                  data(pp + (16 + 32 * (k - 1) + (0 : 7)));
                            psRng = typecast(uint8(psRngInt8'), 'double');
                            
                            Data.prMes(k) = psRng;
                            
                            
                            cpMesInt8 = ...
                                  data(pp + (24 + 32 * (k - 1) + (0 : 7)));
                            cpMes = typecast(uint8(cpMesInt8'), 'double');
                            
                            Data.cpMes(k) = cpMes;
                            
                            
                            dopplMesUInt8 = ...
                                data(pp + (32 + 32 * (k - 1) + (0 : 3)));
                            dopplMes = typecast(uint8(dopplMesUInt8'), ...
                                                                'single');
                            Data.doMes(k) = dopplMes;
                            
                            
                            Data.gnssId(k) = data(pp + (36 + 32 * (k - 1)));
                            
                            Data.svId(k) = data(pp + (37 + 32 * (k - 1)));
                            Data.reserved2(k) = ...
                                            data(pp + (38 + 32 * (k - 1)));
                            Data.freqId(k) = data(pp + (39 + 32 * (k - 1)));
                            
                            
                            lockTimeUInt8 = data(pp + (40 + 32 * (k - 1) + ...
                                                                 (0 : 1)));
                            lockTime = typecast(uint8(lockTimeUInt8'), ...
                                                                 'uint16');
                            Data.lockTime(k) = lockTime;
                            
                            
                            Data.cn0(k) = data(pp + (42 + 32 * (k - 1)));
                            
                            
                            n = data(pp + (43 + 32 * (k - 1)));
                            Data.prStdev(k) = 0.01 * 2 ^ n;
                            
                            
                            mult = data(pp + (44 + 32 * (k - 1)));
                            Data.cpStdev(k) = 0.004 * mult;
                            
                            n = data(pp + (45 + 32 * (k - 1)));
                            Data.doStdev(k) = 0.002 * 2 ^ n;
                            
                            Data.trkStat{k} = ...
                                  dec2bin(data(pp + (46 + 32 * (k - 1))));
                        end
                        Mes0x1502{cnt1502} = Data;
                        Data = [];
                        
                    case hex2dec('3501') 
                        cnt0135 = cnt0135 + 1;
                        pp = pos + 6;
                        Data.tow =   data(pos + 9) * 2^24    + ...
                                data(pos + 8) * 2^16    + ...
                                data(pos + 7) * 2^8     + ...
                                data(pos + 6) * 2^0;
                            
                        version = data(pp + 4);
                        Data.version = typecast(uint8(version), 'uint8');
                        
                        Data.num_svs = data(pp + 5);
%                         Data.num_svs = typecast(uint8(num_svs), 'uint8');
                        
                        for n = 1 : Data.num_svs
                            Data.gnss_id(n) = data(pp + (8   + 12 * (n -1)));
                            Data.sv_id(n)      = data(pp + (9   + 12 * (n -1)));
                            Data.cn0(n)       = data(pp + (10 + 12 * (n -1)));
                            elev                     = data(pp + (11 + 12 * (n -1)));
                            Data.elev(n)     = typecast(uint8(elev), 'int8');
%                             ff   = data(pp + (40 + 32 * (n - 1) + 0 : 2));
                            pr_res =    data(pp + (14 + 12 * (n - 1) + (0 : 1)));
                            Data.pr_res(n) = 0.1 * typecast(uint8(pr_res), 'int16');
                            Data.flags{n}  = data(pp + (16 + 12 * (n -1) + (0 : 3)));
                        end
                        Mes0x0135{cnt0135} = Data;
                        Data = [];
                  
                    case hex2dec('0101')
                        cnt0101 = cnt0101 + 1;
                        pp = pos + 6;
                        Data.tow =   data(pos + 9) * 2^24    + ...
                                data(pos + 8) * 2^16    + ...
                                data(pos + 7) * 2^8     + ...
                                data(pos + 6) * 2^0;
                        
                        x_ecef_cm = data(pp + (4 : 7));
                        Data.x_ecef = typecast(uint8(x_ecef_cm), 'int32');

                        y_ecef_cm = data(pp + (8 : 11));
                        Data.y_ecef = typecast(uint8(y_ecef_cm), 'int32');

                        z_ecef_cm = data(pp + (12 : 15));
                        Data.z_ecef = typecast(uint8(z_ecef_cm), 'int32');

                        acc = data(pp + (16 : 19));
                        Data.acc = typecast(uint8(acc), 'uint32');

                        Mes0x0101{cnt0101} = Data;
                        Data = [];
                    case hex2dec('0201')
                        cnt0102 = cnt0102 + 1;
                        pp = pos + 6;
                        Data.tow =   data(pos + 9) * 2^24    + ...
                                data(pos + 8) * 2^16    + ...
                                data(pos + 7) * 2^8     + ...
                                data(pos + 6) * 2^0;
                        
                        lon = data(pp + (4 : 7));
                        Data.lon = typecast(uint8(lon), 'int32');

                        lat = data(pp + (8 : 11));
                        Data.lat = typecast(uint8(lat), 'int32');

                        height = data(pp + (12 : 15));
                        Data.height = typecast(uint8(height), 'int32');

                        height_msl = data(pp + (16 : 19));
                        Data.height_msl = typecast(uint8(height_msl), 'int32');

                        horiz_acc = data(pp + (20 : 23));
                        Data.height_acc = typecast(uint8(horiz_acc), 'uint32');

                        vert_acc = data(pp + (24 : 27));
                        Data.height_acc = typecast(uint8(vert_acc), 'uint32');

                        Mes0x0102{cnt0102} = Data;
                        Data = [];

%                     case hex2dec('3001')
%                         pp  	=   pos + 6;
%                         numSvs  = 	data(pp + 4);
%                         tow2(cnt_el) =	data(pp + 3) * 2^24    + ...
%                                         data(pp + 2) * 2^16    + ...
%                                         data(pp + 1) * 2^8     + ...
%                                         data(pp + 0) * 2^0;
%                         for ii = 1:numSvs
%                             pp2     = pp + (ii - 1)*12;
%                             chn     = data(pp2 + 8);
%                             svId  	= data(pp2 + 9);
% 
%                             cno(svId, cnt_el)  	= data(pp2 + 12);
%                             el(svId, cnt_el)  	= data(pp2 + 13);
%                             az(svId, cnt_el)	= data(pp + 15) * 2^8 + ...
%                                                     data(pp + 14) * 2^0;
%                             qual    = data(pp2 + 11);
%                         end
%                         cnt_el = cnt_el + 1;
%                     case hex2dec('3501')
%                         pp      =   pos + 6;
%                         tow3    =	data(pp + 3) * 2^24    + ...
%                                     data(pp + 2) * 2^16    + ...
%                                     data(pp + 1) * 2^8     + ...
%                                     data(pp + 0) * 2^0;

                end
%{
                if(command == command_p)
                    wr = 1;
                    if(nargin > 2)
                        if(varargin{1} > 256)
                            tt =    data(pos + 15) * 256^3 + ...
                                    data(pos + 14) * 256^2 + ...
                                    data(pos + 13) * 256^1 + ...
                                    data(pos + 12) * 256^0;
                        else
                            tt = data(pos + 12);
                        end
                        wr = (tt == varargin{1});
                    end
                    if(wr)
                        d = (length_p + 3) * 4;
                        if((pos + d) <= size)

                            out(cnt_out_data: cnt_out_data + d - 1) = data(pos: pos + d - 1);
                            cnt_out_data = cnt_out_data + d;
                        end
                    end
                end
%}
                pos = pos + length + 8;
            else
                pos = pos + 1;
            end
        end 
        pp = (portion * portPos)/size_all * 100;
        if(pp > 100) pp = 100; end
        pp

    end
    fclose(file);
end

end