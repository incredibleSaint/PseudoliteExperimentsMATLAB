function E = SolvKeplerEq(M, e, epsilon)
   	En    = M;
	delta = (En-e*sin(En)- M)/(1 - e*cos(En));
    
	while ( abs(delta) > epsilon )
	    delta = (En - e*sin(En) - M)/(1 - e*cos(En));
        En = En - delta;
    end
 	E = En;
end