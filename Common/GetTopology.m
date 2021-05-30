function [Pseudolite, UPos, topology] = GetTopology()
% Get Pseudolite Coordinates:
% Cube Topology:

% ---- Receiver Positions --------

% cubeLength = 1000;
% Pseudolite{1}.x = cubeLength;
% Pseudolite{1}.y = cubeLength;
% Pseudolite{1}.z = cubeLength;
% 
% Pseudolite{2}.x = 0;
% Pseudolite{2}.y = cubeLength;
% Pseudolite{2}.z = cubeLength;
% 
% Pseudolite{3}.x = 0;
% Pseudolite{3}.y = 0;
% Pseudolite{3}.z = cubeLength;
% 
% Pseudolite{4}.x = cubeLength;
% Pseudolite{4}.y = 0;
% Pseudolite{4}.z = cubeLength;




% ==================================
% ---- Rombus topology --- 
% topology = "Rombus topology";
% d = 200;
% x = d / tand(40);
% S = 1 / 2 * 2 * d * 2 * x;
% height = 20;
% 
% Pseudolite{1}.x = 0;
% Pseudolite{1}.y = x;
% Pseudolite{1}.z = height + 10;
% 
% Pseudolite{2}.x = d;
% Pseudolite{2}.y = 0;
% Pseudolite{2}.z = height - 10;
% 
% Pseudolite{3}.x = 2 * d;
% Pseudolite{3}.y = x;
% Pseudolite{3}.z = height;
% 
% Pseudolite{4}.x = d;
% Pseudolite{4}.y = 2 * x;
% Pseudolite{4}.z = height;
% 
% % 
% % % ----- UserPosition -----------
% UPos.z = 0;
% gridValX = 20 : 50 : 100;
% gridValY = 20 : 40 : 100;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);


% ==================================
% ======== Pyramide topology =======
% d = 10;
% x = d / tand(60);
% S = 1 / 2 * 2 * d * 2 * x;
% height = 10;
% 
% Pseudolite{1}.x = 0;
% Pseudolite{1}.y = x;
% Pseudolite{1}.z = height;
% 
% Pseudolite{2}.x = d;
% Pseudolite{2}.y = 0;
% Pseudolite{2}.z = height;
% 
% Pseudolite{3}.x = 2 * d;
% Pseudolite{3}.y = x;
% Pseudolite{3}.z = height;
% 
% Pseudolite{4}.x = d;
% Pseudolite{4}.y = 0.8 * x;
% Pseudolite{4}.z = 3 * height;
% 
% %----- UserPosition -----------
% UPos.z = 0;
% gridValX = 0 +2 : 0.1 : 2 * d -4;
% gridValY = 0 : 0.1 : 2 * x;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);


% ==================================
% === Ideal GDOP (120 degrees) =====
% 
% topology = "Ideal_GDOP_tetrahedron";
% r = 200;
% pr_x = r * sind(30);
% pr_y = r * cosd(30);
% 
% height = 100;
% 
% height_zenith = height * 3;
% 
% Pseudolite{1}.x = r;
% Pseudolite{1}.y = 0;
% Pseudolite{1}.z = height;
% 
% Pseudolite{2}.x = -pr_x;
% Pseudolite{2}.y =  pr_y;
% Pseudolite{2}.z = height;
% 
% Pseudolite{3}.x = -pr_x;
% Pseudolite{3}.y = -pr_y;
% Pseudolite{3}.z = height;
% 
% Pseudolite{4}.x = 0;
% Pseudolite{4}.y = 0;
% Pseudolite{4}.z = height_zenith;
% 
% %----- UserPosition -----------
% UPos.z = 0;
% gridValX = -50 : 50 : 100 ;
% gridValY = -50 : 50 : 100 ;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);
%===========================


% ==================================
% ==== Pseudolite Rombus Array =====
topology = "cell rombus array";
d_x = 500;%8.68;
d_y = d_x / tand(50);
side = sqrt(d_x ^ 2 + d_y ^ 2);

S = 1 / 2 * 2 * d_x * 2 * d_y;
height = 15;

Pseudolite{1}.x = -d_x;
Pseudolite{1}.y = 0;
Pseudolite{1}.z = height;

Pseudolite{2}.x = 0;
Pseudolite{2}.y = d_y;
Pseudolite{2}.z = height;

Pseudolite{3}.x = d_x;
Pseudolite{3}.y = 0;
Pseudolite{3}.z = height;

Pseudolite{4}.x = 0;
Pseudolite{4}.y = -d_y;
Pseudolite{4}.z = height;

Pseudolite{5}.x = -d_x;
Pseudolite{5}.y = side;
Pseudolite{5}.z = height;

Pseudolite{6}.x = 0;
Pseudolite{6}.y = d_y + side;
Pseudolite{6}.z = height;

Pseudolite{7}.x = d_x;
Pseudolite{7}.y = side;
Pseudolite{7}.z = height;

Pseudolite{8}.x = -d_x;
Pseudolite{8}.y = -side;
Pseudolite{8}.z = height;

Pseudolite{9}.x = 0;
Pseudolite{9}.y = -(d_y + side);
Pseudolite{9}.z = height;

Pseudolite{10}.x = d_x;
Pseudolite{10}.y = -side;
Pseudolite{10}.z = height;

Pseudolite{11}.x = -2 * d_x;
Pseudolite{11}.y = -(d_y + side);
Pseudolite{11}.z = height;

Pseudolite{12}.x = -2 * d_x;
Pseudolite{12}.y = -d_y;
Pseudolite{12}.z = height;

Pseudolite{13}.x = -2 * d_x;
Pseudolite{13}.y = d_y;
Pseudolite{13}.z = height;

Pseudolite{14}.x = -2 * d_x;
Pseudolite{14}.y = d_y + side;
Pseudolite{14}.z = height;

Pseudolite{15}.x = -d_x;
Pseudolite{15}.y = d_y + side + d_y;
Pseudolite{15}.z = height;

Pseudolite{16}.x = 2 * d_x;
Pseudolite{16}.y = -(d_y + side);
Pseudolite{16}.z = height;

Pseudolite{17}.x = 2 * d_x;
Pseudolite{17}.y = -d_y;
Pseudolite{17}.z = height;

Pseudolite{18}.x = 2 * d_x;
Pseudolite{18}.y = d_y;
Pseudolite{18}.z = height;

Pseudolite{19}.x = 2 * d_x;
Pseudolite{19}.y = d_y + side;
Pseudolite{19}.z = height;

Pseudolite{20}.x = d_x;
Pseudolite{20}.y = d_y + side + d_y;
Pseudolite{20}.z = height;

Pseudolite{21}.x = -3 * d_x;
Pseudolite{21}.y = 0;
Pseudolite{21}.z = height;

Pseudolite{22}.x = 3 * d_x;
Pseudolite{22}.y = 0;
Pseudolite{22}.z = height;

Pseudolite{23}.x = 0;
Pseudolite{23}.y = d_y + side + 2 * d_y;
Pseudolite{23}.z = height;

% Pseudolite{24}.x = 0;
% Pseudolite{24}.y = 0;
% Pseudolite{24}.z = height;
% ----- UserPosition -----------
UPos.z = 0;
coeffSq = 3;
% gridValX = -coeffSq * d_x: coeffSq * d_x / 5 : coeffSq * d_x;
% gridValY = -coeffSq * d_y : coeffSq * d_x / 5 : d_y + side + d_y;
gridValX = [-1410 -1210 -600 0  170 440 920 1400];
gridValY = 0;
[UPos.x, UPos.y] = meshgrid(gridValX, gridValY);


% ==================================
% === Real Exp =====

% topology = "Real Experiment Poses";
% % r = 200;
% % pr_x = r * sind(30);
% % pr_y = r * cosd(30);
% 
% % height = 100;
% 
% % height_zenith = height * 3;
% 
% 
% wgs84 = wgs84Ellipsoid('meter');


%--- 13 floor (Glass) ---
% lat = 59.992728;
% lon = 30.380735;
% h = 70;
% 
% [x,y,z] = geodetic2ecef(wgs84, lat, lon, h, 'degrees');
% 
% Pseudolite{1}.x = x;
% Pseudolite{1}.y = y;
% Pseudolite{1}.z = z;
% 
% % --- Main building ----
% lat = 59.993033;
% lon = 30.379111;
% h = 58;
% 
% [x,y,z] = geodetic2ecef(wgs84, lat, lon, h, 'degrees');
% 
% Pseudolite{2}.x = x;
% Pseudolite{2}.y = y;
% Pseudolite{2}.z = z; 
% 
% % --- Bridge (near main building) ---
% lat = 59.992866;
% lon = 30.377676;
% h = 27;
% 
% [x,y,z] = geodetic2ecef(wgs84, lat, lon, h, 'degrees');
% 
% 
% Pseudolite{3}.x = x;
% Pseudolite{3}.y = y;
% Pseudolite{3}.z = z;
% 
% 
% % --- Brigdge (near railway) ---
% lat = 59.992484;
% lon = 30.377308;
% h = 27;
% 
% [x,y,z] = geodetic2ecef(wgs84, lat, lon, h, 'degrees');
% 
% 
% Pseudolite{4}.x = x;
% Pseudolite{4}.y = y;
% Pseudolite{4}.z = z;
% 
% %----- UserPosition -----------
% lat = 59.992610;
% lon = 30.379479;
% [x,y,z] = geodetic2ecef(wgs84, lat, lon, h, 'degrees');
% 
% UPos.z = z;
% gridValX = x + (0 : 10 : 20);
% gridValY = y + (0 : 10 : 20) ;
% [UPos.x, UPos.y] = meshgrid(gridValX, gridValY);
%===========================

%======== End Topology ==================

% == Plot Topology =========


flag_draw = 1;
flag_2D = 1;
flag_3D = 1;

if flag_draw
    s = size(Pseudolite);
    
    if flag_2D 
        figure; hold on;
        grid on; title("Pseudolite Array");
        
        for n = 1 : s(2)
            if flag_2D
                scatter(Pseudolite{n}.x, Pseudolite{n}.y, 100, 'g', 'filled');
            end
            text(Pseudolite{n}.x, Pseudolite{n}.y, num2str(n)); 
        end
        xlabel("X, м");
        ylabel("Y, м");
    end
    
    if flag_3D 
        figure; hold on;
        grid on; title("Pseudolite Array");
        
        for n = 1 : s(2)
            if flag_3D
                plot3(Pseudolite{n}.x, Pseudolite{n}.y, Pseudolite{n}.z, ...
                       'Marker', '+', 'LineWidth', 1);
            end
            text(Pseudolite{n}.x, Pseudolite{n}.y, num2str(n)); 
        end
        xlabel("X, м");
        ylabel("Y, м");
    end
    
    
end
end

