% ISTENSOR3   True for tensor3 variables.
%
%    Determines if a variable is a tensor3, that is, a numeric of size oxmxn 
%    where o, n and m (even all) can be equal to 1.
%
% FORMAT   bool = istensor3(a)
%        
% OUT   bool   true if tensor3, else false.
% IN    a      A variable of any data type.

% 2005-03-16  Created by Patrick Eriksson. 


function bool = istensor3( a )

bool = isnumeric( a )  &&  dimens(a) <= 3;


