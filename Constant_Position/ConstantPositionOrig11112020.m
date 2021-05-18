% Here I show that pseudolite coordinates couldn't be calculated from
% standard nav message, because there is not enough range for delta_n:

% Coordinates, which we want to emulate:
% xOrig = 1.210019751660922e+07;
% yOrig = 6.986052293461972e+06;
% zOrig = 2.416332458549329e+07;
xOrig = 2.768817092102082e+06;
yOrig = 1.598577293461974e+06;
zOrig = 5.500563736479017e+06;
%----- Constants -----------------------
u = 3.986004418e14;
OMEGAdot_e = 7.2921150e-5;
pi = 3.1415926535898;
C = 2.99792458e8;

% ---- Modification ---------------------
s2.C_uc = 0;
s2.C_us = 0;
s2.e = 0;
s2.t_oe = 0;
s3.IDOT = 0;
s3.C_ic = 0;
s3.C_is = 0;
s2.C_rc = 0;
s2.C_rs = 0;
s2.M_0 = 0;%!!!! не указано в статье
%----------------------------------------
s3.OMEGA_0 = atan(-xOrig/yOrig);
s3.OMEGA_dot = OMEGAdot_e;
t = 2000;
t_k = t - s2.t_oe;
OMEGA_k = s3.OMEGA_0 +(s3.OMEGA_dot - OMEGAdot_e)*t_k - OMEGAdot_e*s2.t_oe;
s3.i_0 = atan(-zOrig*sin(OMEGA_k)/xOrig);
i = s3.i_0;
s2.sqrt_A = sqrt(zOrig/sin(i));
s3.w = pi/2;
s2.delta_n = -sqrt(u/(s2.sqrt_A^2)^3);
%------ End Modification ----------

%------ End Transmitter -----------------

%------ ... Channel ... -----------------

%--- Receiver Algoritm ------------------
A = s2.sqrt_A^2; 
n_0 = sqrt(u/A^3);
F = -2*sqrt(u)/C^2;

t_oc = s2.t_oe;%t_oc~t_oe(because of there is no t_oc in .rnx files v3.xx)
%--------- Non-important in this algorithm ------------
s1.a_0 = 1;
s1.a_1 = 1;
s1.a_2 = 1;
s1.T_GD1 = 12e-9;
%--------- End Non-imp ------------

delta_t_sv = s1.a_0 + s1.a_1*(t-t_oc)+s1.a_2*(t-t_oc)^2 - s1.T_GD1*1e-9 ;

t = t - delta_t_sv;
t_k = t - s2.t_oe;
n = n_0 + s2.delta_n;
M_k = s2.M_0 + n*t_k;
epsilon = 1e-12;
E_k   = rem(SolvKeplerEq(M_k, s2.e, epsilon), 2*pi);
v_k  = atan2(sqrt(1 - s2.e^2) * sin(E_k), cos(E_k)-s2.e);
phi = rem(v_k + s3.w,2*pi);

delta_u_k = s2.C_us * sin(2*phi) + s2.C_uc * cos(2*phi);
delta_r_k = s2.C_rs * sin(2*phi) + s2.C_rc * cos(2*phi);
delta_i_k = s3.C_is * sin(2*phi) + s3.C_ic * cos(2*phi);

u_k = phi + delta_u_k;
r_k = A*(1 - s2.e*cos(E_k)) + delta_r_k;
i_k = s3.i_0 + s3.IDOT*t_k + delta_i_k;

x_k = r_k*cos(u_k);
y_k = r_k*sin(u_k);
OMEGA_k = s3.OMEGA_0 + (s3.OMEGA_dot - OMEGAdot_e)*t_k - OMEGAdot_e*s2.t_oe;

No_sv = 7;
if No_sv > 5 % => MEO/IGSO satellite
%     OMEGA_k = s3.OMEGA_0 +(s3.OMEGA_dot - OMEGAdot_e)*t_k-OMEGAdot_e*s2.t_oe;
    X_k = x_k*cos(OMEGA_k) - y_k*cos(i_k)*sin(OMEGA_k);
    Y_k = x_k*sin(OMEGA_k) + y_k*cos(i_k)*cos(OMEGA_k);
    Z_k = y_k*sin(i_k);
else % => GEO satellite
%     OMEGA_k = s3.OMEGA_0 + s3.OMEGA_dot*t_k - OMEGAdot_e*s2.t_oe;
    X_GK= x_k*cos(OMEGA_k) - y_k*cos(i_k)*sin(OMEGA_k);
    Y_GK = x_k*sin(OMEGA_k) + y_k*cos(i_k)*cos(OMEGA_k);
    Z_GK = y_k*sin(i_k);
    phi_x = -0.0872665;
    R_x = [1 0 0; 0 cos(phi_x) sin(phi_x); 0 -sin(phi_x) cos(phi_x)];
    
    phi_z = OMEGAdot_e*t_k;
    R_z = [cos(phi_z) sin(phi_z) 0; -sin(phi_z) cos(phi_z) 0; 0 0 1];
    R = R_z*R_x;
    A = R*[X_GK ;Y_GK; Z_GK ];
    X_k = A(1);
    Y_k = A(2);
    Z_k = A(3);
end
dR = sqrt((xOrig - X_k) ^ 2 + (yOrig - Y_k) ^ 2 + (zOrig - Z_k) ^ 2);
fprintf("Разница имитируемого положения и рассчитанного в приемнике %d\n м",...
                                                                       dR);