function [ modulated_code ] = Neumann_Hoffman( code )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
NH_code = [0 0 0 0 0 1 0 0 1 1 0 1 0 1 0 0 1 1 1 0]; 
NH_inv =  [1 1 1 1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1];
len_NH = 20;
modulated_code = zeros(1,len_NH*length(code));

for i = 1:length(code)
    if code(i) == 0
        modulated_code((i-1)*len_NH+1:i*len_NH)=NH_code;
    else 
        modulated_code((i-1)*len_NH+1:i*len_NH)=NH_inv;
    end
end
end

