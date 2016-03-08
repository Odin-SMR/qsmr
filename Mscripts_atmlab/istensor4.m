% ISTENSOR4   True for tensor4 variables.
%
%    Determines if a variable is a tensor3, that is, a numeric of size oxmxn 
%    where o, n and m (even all) can be equal to 1.
%
% FORMAT   bool = istensor4(a)
%        
% OUT   bool   true if tensor3, else false.
% IN    a      A variable of any data type.

% 2005-03-16  Created by Patrick Eriksson. 


function bool = istensor4( a )

bool = isnumeric( a )  &&  dimens(a) <= 4;


