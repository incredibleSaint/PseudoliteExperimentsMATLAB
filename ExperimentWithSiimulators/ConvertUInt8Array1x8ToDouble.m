function doubleValue = ConvertUInt8Array1x8ToDouble(uint8String)
% Вх параметр:
% UInt8String - массив 1x8 (строка), элементы которого записаны
% в формате 'uint8', 'right-msb'

% Выходной параметр:
% doubleValue - число в формате double
% flipString  = fliplr(uint8String);
doubleValue = typecast(uint8(uint8String), 'double'); 

end

