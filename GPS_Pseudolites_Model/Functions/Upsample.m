function [ bi_codeX4 ] = Upsample( bi_code , SamplingFrequency )

bi_codeX4 = zeros( 1 , SamplingFrequency*length(bi_code) );% 2*length(bi_code)

k = 0;
m = SamplingFrequency-1;
for i = 1:1:length(bi_code)
    k = k+1;
    for k = k:1:(k+m)%for k = k:1:(k+3)
          bi_codeX4(k) = bi_code(i);
    end
end

end

