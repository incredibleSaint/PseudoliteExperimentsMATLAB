function doubleValue = ConvertUInt8Array1x8ToDouble(uint8String)
% �� ��������:
% UInt8String - ������ 1x8 (������), �������� �������� ��������
% � ������� 'uint8', 'right-msb'

% �������� ��������:
% doubleValue - ����� � ������� double
% flipString  = fliplr(uint8String);
doubleValue = typecast(uint8(uint8String), 'double'); 

end

