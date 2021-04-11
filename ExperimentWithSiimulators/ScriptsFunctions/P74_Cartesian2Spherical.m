function [Lat, Lon, Alt] = P74_Cartesian2Spherical(xyz)
% Функция выполняет преобразование координат из прямоугольной системы
% координат в сферическую систему координат
%
% Входные параметры
%   x, y, z - координаты в прямоугольной системе координат в метрах.
%
% Выходные параметры
%   Latitude, Longitude, Altitude - широта и долгота в радианах, высота в
%     метрах.

    AlgType = 0;
        % 0 - по стандарту РФ
        % 1 - по книге
        
    EllipseType = 0;
        % 0 - WGS84
        % 1 - ПЗ-90
        % 2 - Красовский - 1942
        
    % ellipticity
        switch EllipseType
            case 0
                ell = 1/298.257223563; % WGS84
            case 1
                ell = 1/298.257839303; % ПЗ-90
            case 2
                ell = 1/298.3; % Красовский - 1942
        end
        
    % semi-major axe of the earth
        switch EllipseType
            case 0
                a = 6378137; % WGS84
            case 1
                a = 6378136; % ПЗ-90
            case 2
                a = 6378245; % Красовский - 1942
        end
        
    % Вызов нужного алгоритма
        if AlgType == 0
            [Lat, Lon, Alt] = Cartesian2Spherical0(xyz, ell, a);
        else
            [Lat, Lon, Alt] = Cartesian2Spherical1(xyz, ell, a);
        end
end 
        
function [Lat, Lon, Alt] = Cartesian2Spherical0(xyz, ell, a)
% Вытащим координаты из вектора
    X = xyz(1);
    Y = xyz(2);
    Z = xyz(3);
    
    e = sqrt(2*ell - ell^2);
    
% Сам расчёт
    D = sqrt(X^2 + Y^2);

    if D == 0
        B = (pi/2) * sign(sign(Z) + 0.5);
        L = 0;
        H = Z * sin(B) - a*sqrt(1-(e*sin(B))^2);            
    else
        La = abs(asin(Y/D));
        if     (Y < 0) && (X > 0)
            L = 2*pi - La;
        elseif (Y < 0) && (X < 0)
            L = pi + La;
        elseif (Y > 0) && (X < 0)
            L = pi - La;
        elseif (Y > 0) && (X > 0)
            L = La;
        elseif (Y == 0) && (X > 0)
            L = 0;
        elseif (Y == 0) && (X <= 0)
            L = pi;
        end

        if Z == 0
            B = 0;
            H = D - a;
        else
            r = sqrt(X^2 + Y^2 + Z^2);
            c = asin(Z/r);
            p = e^2*a/(2*r);

            s1 = 0;

            Error = inf;
            NumIters = 0;
            while (Error > 1e-18) && (NumIters < 100)
                b = c + s1;
                s2 = asin(p*sin(2*b)/sqrt(1-(e*sin(b))^2));
                Error = abs(s2 - s1);
                s1 = s2;
                NumIters = NumIters + 1;
            end

            B = b;
            H = D*cos(B) + Z*sin(B) - a*sqrt(1-(e*sin(B))^2);
        end
    end
        
% Сохранение результатов
    Lat  = B;
    if L > pi
        L = -(2*pi - L);
    end
    Lon = L;
    Alt  = H;
    
end
    
function [Lat, Lon, Alt] = Cartesian2Spherical1(xyz, ell, a)
% Вытащим координаты из вектора
    x = xyz(1);
    y = xyz(2);
    z = xyz(3);

% Сам расчёт
    r = (x^2 + y^2 + z^2)^.5;
    Geocentric_Latitude = atan(z/(x^2+y^2)^.5);
    Lon = atan(y/x);
        
    Geodetic_Latitude_Old = Geocentric_Latitude;
    Error = 1;
    NumIters = 0;
    while (Error > 1e-18) && (NumIters < 100)
        Geodetic_Latitude = Geocentric_Latitude + ...
            ell*sin(2*Geodetic_Latitude_Old);
        Error = abs(Geodetic_Latitude_Old - Geodetic_Latitude);
        Geodetic_Latitude_Old = Geodetic_Latitude;
        NumIters = NumIters + 1;
    end
    Lat = Geodetic_Latitude;
    
    Alt = r - a*(1-ell*(sin(Geodetic_Latitude)^2));
end