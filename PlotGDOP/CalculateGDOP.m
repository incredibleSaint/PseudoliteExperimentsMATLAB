% SHAIK RIYAAZ UDDIEN- SAPIENZA UNIVERSITY OF ROME, ITALY
% Matlab Code to find out the position of Satellites using Orbital Parameters for time duration of 24 hours
% Satellite Constellation
% Ref: YUMA ALMANAC - US COAST GUARD SITE

function [GDOP, PDOP, HDOP, VDOP] = CalculateGDOP(Pseudolite, userPos)
% RE = 6378000;                       % Earth's radius                        [m]
% muE = 3.986004418e+14;              % Earth gravitational parameter         [m^3/sec^2]
% 
% sa = [5153.653320^2 5153.606445^2 5153.542969^2 5153.562012^2 5153.740723^2 5153.577637^2 5153.717285^2 5153.704102^2 5153.624512^2 5153.617188^2 5153.59912^2 5153.634766^2 5153.541016^2 5153.624512^2 5153.543457^2 5153.713867^2 5153.660645^2  5153.585938^2 5153.533691^2 5153.751465^2 5153.631348^2 5153.538086^2 5153.669922^2 5153.639160^2 5153.549316^2 5153.604980^2 5153.591309^2 5153.683105^2 5153.708008^2 5153.531250^2 5153.600586^2]; % SEMI-MAJAR AXIS PARAMETER
% 
% Meananom=[-0.1208933778e+001 -0.7379312701e+000 -0.2476050596e+001 0.1729284331e+001 -0.5955965034e+000 -0.1863089325e+001 0.1717615066e+001 0.1041308928e+001 0.3003120927e+001 -0.1772399827e+001 -0.2456528294e+001 -0.8542115828e+000 0.4893275126e+000 0.1755864967e+000 0.1876034910e+001 0.8991835103e+000 0.2479146271e+001 -0.2239168159e+001 0.5016783799e-001 -0.2845982272e+001 0.4089099929e+000 -0.3331816757e+000 -0.8946785652e+000 -0.2992513015e+001  0.2928989882e+001 0.9610869005e+000 0.1794198757e+001 0.2993612193e+001 -0.1855898041e+001 -0.2008106311e+001 0.1461498698e+001]; % MEAN ANOMALY
% 
% arg=[0.563527841 -2.074941210 0.718299986 0.536422146 -1.700786593 -2.620313325 -1.011684673 1.869199782 -2.911753571  1.589303341 0.783939084  1.923932861 -1.944528126  0.517680691 0.382938305 -1.917666234 -1.854486524 0.879175098 1.466748537 -1.748448979 -1.854394021 -2.525418487 0.394514692 0.771921528 -0.184188174 0.328577112 -1.607607372 0.029954945 -3.122813373 -0.369073306 -2.439273631]; % ARGUMENT OF PERIGEE
% 
% orbinc=[0.9651879023 0.9440357453 0.9595553166 0.9465644168 0.9649961547 0.9644988093 0.9649302414 0.9547136897 0.9597590484 0.8981062034  0.9901450506 0.9709223539 0.9634382054 0.9304156737 0.9906543802 0.9780709440 0.9252444807 0.9752067143 0.9265148085 0.9373066030 0.9232011703 0.9456176630 0.9475830759 0.9782207469 0.9601005988 0.9730315775 0.9893960366 0.9790955953 0.9502675423 0.9692924993 0.9592676952]; % INCLINATION
% 
% RAANangle=[0.1489908052e+001 0.1441165588e+001 0.2532003819e+001 0.2518117098e+001 0.1481505987e+001 -0.1634831037e+001 0.4283431626e+000 -0.2713451725e+001 0.2528123551e+001 0.1102367430e+001  -0.5551591071e+000 -0.2590521291e+001 -0.2628516527e+001 -0.2769660736e+001 -0.5363502406e+000 0.4829410443e+000 0.2493819082e+001 0.5313011368e+000 0.2442215384e+001 0.1452076850e+001 0.2494154640e+001 -0.2709604040e+001 -0.1684579427e+001 -0.6078234089e+000 -0.6194110309e+000 0.4322024576e+000 -0.5315595467e+000  0.4928152966e+000 -0.1592779889e+001 -0.1624817468e+001 -0.2711327521e+001]; % RAAN ANGLE
% 
% eccen=[0.5968570709e-002 0.1603031158e-001 0.2923011780e-003 0.4848480225e-002 0.2102851868e-003 0.1005315781e-001 0.1864910126e-002 0.6208419800e-003 0.1812458038e-002  0.1681089401e-001 0.6042003632e-002  0.4010200500e-002 0.8724212646e-002 0.8650302887e-002 0.8711338043e-002 0.1133203506e-001 0.1726150513e-001 0.1039505005e-001 0.4734039307e-002 0.2335453033e-001 0.7355213165E-002 0.1113939285e-001 0.4827976227e-002 0.5622386932e-002 0.1107215881E-002 0.3872394562e-002 0.2001571655e-001 0.5064010620e-003 0.2400398254e-002 0.8392333984e-002 0.6222724915e-003]; % ECCENTRICITY
% 
% numofsat=1:1:31;

% for m=1:length(numofsat)
%     Mo=Meananom(1,m);                    % Mean anomaly of satellite
%     RAAN  = RAANangle(1,m);              % RAAN                          [rad]
%     w     = arg(1,m);                    % Argument of perigee           [rad]
%     inc   = orbinc(1,m);                 % inclination                   [rad]
%     ecc   = eccen(1,m);                  % eccentricity
%     a     = sa(1,m);                     % semi-major axis               [m]
%     n     = sqrt(muE/a^3);               % Mean Motion                   [rad/s]
% 
%     t=24*60*60;                          % time span (24 hrs)
%     J=1:600:t;                           % 10 minutes
% 
%     xs=zeros(1,72);
%     ys=zeros(1,72);
%     zs=zeros(1,72);
%         for k=1:length(J)
%         Mi=Mo+n*J(k);
%         Tol = 0.001;
%         E1=Mi;
%         E2=E1-((E1-ecc*(sin(E1))-Mi)/(1-ecc*(cos(E1)))); % NEWTON-RAPHSON APPROACH
%         error=100;
%                 while error > Tol
%                 E1=E2;
%                 E2=E1-((E1-ecc*(sin(E1))-Mi)/(1-ecc*(cos(E1))));
%                 error=abs(E2-E1);
%                 end
%          r=a*(1-ecc*cos(E2)); % RADIUS
%          b=2*atan(sqrt((1-ecc)/(1+ecc))*tan(E2/2)); % TRUE ANOMALY
%          u = w+b;
%         X=r*cos(u); % IN-PLANE
%         Y=r*sin(u); % IN-PLANE
%         xs(:,k) = X*cos(RAAN)-Y*cos(inc)*sin(RAAN);    % ECEF x-coordinate SAT         [m]
%         ys(:,k) = X*sin(RAAN)+Y*cos(inc)*cos(RAAN);    % ECEF y-coordinate SAT         [m]
%         zs(:,k) = Y*sin(inc);                                % ECEF z-coordinate SAT         [m]
%         end
% Xs(m,:)=[xs];
% Ys(m,:)=[ys];
% Zs(m,:)=[zs];
% end
%plot3(Xs,Ys,Zs,'.') % SATELLITE CONSTELLATION

%hold on

% LAT AND LONG FOR ROME

% lat=0.731213823356; %latitute in radians
% long=0.2178576521;  %longitute in radians
% x=RE*cos(lat)*cos(long);
% y=RE*cos(lat)*sin(long);
% z=RE*sin(lat);


% sizeStruct = size(RXPoses);
% for p = 1 : sizeStruct(1) * sizeStruct(2) 
    
q=1;

%--------------------

x = userPos.xEast;
y = userPos.yNorth;
z = userPos.zUp;
% numofsat = 1 : length(RXPoses{p}.SatsPoses.x);
%---------------------
s = size(Pseudolite);

for m = 1 : s(2)
   
%     xsat=Xs(m,p);
%     ysat=Ys(m,p);
%     zsat=Zs(m,p);
%     -------------------------
    xsat = Pseudolite{m}.xEast;
    ysat = Pseudolite{m}.yNorth;
    zsat = Pseudolite{m}.zUp;

% --------- end -------------------
     
    d=sqrt(((xsat-x)^2)+((ysat-y)^2)+((zsat-z)^2)); %Pseudo-range from ground-station to satellite
    
    r=sqrt(((xsat-0)^2)+((ysat-0)^2)+((zsat-0)^2)); %distance between earth-centre to satellite
    
    a=(x-xsat)/d;
 
    b=(y-ysat)/d;
 
    c=(z-zsat)/d;
     
%     alph=acos((RE^2+d^2-r^2)/(2*RE*d)); % Mask-angle using cosine-triangle concept
%     
%     alph_deg=radtodeg(alph); % Mask-angle in degrees
    
    %----------------------
    H=horzcat(a,b,c, 1);
    
            G(q,:)=H;   %G matrix for visible satellites
            q=q+1;
    %--- end --------------
   
%     if alph_deg>=110 && alph_deg<=250 % Considering elevation angle of 20 degrees from both sides
%          N=1;
%      else
%          N=0;
%     end
%   
%     H=horzcat(a,b,c,N);
%     w
%          if H(1,4)==1   %Removal of rows having zero at 4th column 
%             G(q,:)=H;   %G matrix for visible satellites
%             q=q+1;
%          end
end
% vis_sat(1,p)=sum(G(:,4)==1);
T = G * G';
D = pinv(T);
Tr = (trace(D));
%GDOP for visible satellites:
GDOP = sqrt(Tr);
%--- PDOP -------
TrPDOP = trace(D(1 : 3, 1 : 3));
PDOP = sqrt(TrPDOP);
HDOP = sqrt(D(1, 1) + D(2, 2));
VDOP = sqrt(D(3, 3));