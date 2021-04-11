function enuCoordinates = ECEFtoENU(ECEF, originOfENU, theta, phi)
% FROM "COORDINATE TRANSFORMATIONS"
% ECEF.x, .y, .z - cooridinates which we want transform to ENU system;
% originOfENU.x, .y, .z [(0, 0, 0) of ENU];
% theta - longtitude of originOfENU;
% phi - latitude of originOfENU;

% Turn ECEF to new orientation on East, North, Up directions 
% from originOfENU:
transfMatrixECEFtoENU = [-sin(theta)     , cos(theta)           , 0; ...
                   -sin(phi) * cos(theta),-sin(phi) * sin(theta), cos(phi); ...
                    cos(phi) * cos(theta), cos(phi) * sin(theta), sin(phi)];

% Shift From ECEF(0,0,0) to originOfENU:
shift = [originOfENU.x * sin(theta) - originOfENU.y * cos(theta);
         originOfENU.x * sin(phi) * cos(theta) - ...
         originOfENU.y * sin(phi) * sin(theta) - ...
         originOfENU.z * cos(phi);
        -originOfENU.x * cos(phi) * cos(theta) - ...
         originOfENU.y * cos(phi) * sin(theta) - ...
         originOfENU.z * sin(phi)];
enuCoord = transfMatrixECEFtoENU * [ECEF.x; ECEF.y; ECEF.z] + shift;

enuCoordinates.xEast = enuCoord(1);
enuCoordinates.yNorth = enuCoord(2);
enuCoordinates.zUp = enuCoord(3);
end