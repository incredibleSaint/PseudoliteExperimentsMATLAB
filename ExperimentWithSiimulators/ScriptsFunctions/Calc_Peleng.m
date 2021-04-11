%  Calc_Peleng.m           %
%  Created on: 09:09:14
%      Author: MAP
% ********************** %

function [ azimuth, elevation, R ] = Calc_Peleng( posParams, svParams )
%CALCPELENG Summary of this function goes here
%   Detailed explanation goes here

x = posParams.x;
y = posParams.y;
z = posParams.z;

xk = svParams.x;
yk = svParams.y; %100000000; %
zk = svParams.z;

xx = x - xk;
yy = y - yk;
zz = z - zk;

R = sqrt( xx*xx + yy*yy + zz*zz ); % between sv and user
rp = sqrt(x * x + y * y + z * z); % between center of Earth and user
rsv = sqrt(xk*xk+yk*yk+zk*zk);
%%	через скалярное произведение вычисляется угол места.
%%IntMath::Angle elevation, azimuth;
% 
% scalar = -(x * xx + y * yy + z * zz) / (rp * R);
% elevation = 0.5 * pi - acos(scalar);
alp = acos((R^2+rp^2-rsv^2)/(2*R*rp));
alp = alp*180/pi;
elevation = alp-90;
%%  вычисление азимута
rxy = sqrt(x * x + y * y);
rxyz = rp;

cosll = x / rxy;
sinll = y / rxy;
sintt = z / rxyz;

xn1 = -sintt * cosll;
xn2 = -sintt * sinll;
xn3 = rxy / rxyz;

p1 = xn1 * xx + xn2 * yy + xn3 * zz;
p2 = -sinll * xx + cosll * yy;

azimuth = 0.5 * pi - atan2(p1, p2);

azimuth = 180*azimuth/pi;
if azimuth < 0
    azimuth = azimuth + 360;
end
if azimuth > 360
    azimuth = azimuth - 360;
end

% elevation = 180*elevation/pi;

end

