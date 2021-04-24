function CACode = GenCACode(SigNum, NumCycles)
%
% ������� ���������� �������� ����� �������� (������) C/A ���� ������� GPS,
% �.�. ������-������ ������ ������� 1023.
%  
% SigNum    - ����� ����, 1...63;
% NumCycles - ���������� �������� C/A ���� �� 1023 ������� (1...1000), ��
%   ��������� NumCycles = 1.
%
% CACode    - ������ ������ 1�NumCycles*1023, ���������� NumCycles ��������
%   C/A ����.
if nargin == 1 
   NumCycles = 1;
end
G1 = ones(1, 10);
G2 = ones(1, 10);
G1out = zeros( 1, 1023 );
G2out = zeros( 1, 1023 );
for n = 1 : 1023
    G1out( n ) = G1( 10 );
    G2out( n ) = G2( 10 );
    
    G1fb = xor( G1(3), G1(10) );
    G2fb = mod( sum( G2([ 2, 3, 6, 8, 9, 10]) ), 2 );
    
    G1 = circshift( G1, 1 );
    G2 = circshift( G2, 1 );
    
    G1(1) = G1fb;
    G2(1) = G2fb;
    
end

CodeDelays = [5 6 7 8 17 18 139 140 141 251 252 254 255 256 257 258 469 470 471 472 473 474 509 512 513 514 515 516 859 860 861 862 863 950 947 948 950 67 103 91 19 679 225 625 946 638 161 1001 554 280 710 709 775 864 558 220 397 55 898 759 367 299 1018];
G2i = circshift( G2out, CodeDelays( SigNum ) );
CACode = mod( G1out + G2i , 2 );

for n = 1 : NumCycles - 1
   CACode = [ CACode, CACode ]; 
end
%���� ����������������, ������������� ��, ��������� ��