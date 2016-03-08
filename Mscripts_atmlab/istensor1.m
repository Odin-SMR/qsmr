% ISTENSOR1   True for vector (tensor 1) variables.
%
%    Determines if a variable is a vector, that is, a numeric of size mx1 
%    where m can be equal to 1.
%
% FORMAT   bool = istensor1(a)
%        
% OUT   bool   true if vector, else false.
% IN    a      A variable of any data type.

% 2005-03-16  Created by Patrick Eriksson. 


function bool = istensor1( a )

bool = isempty(a) || (isnumeric(a) && size(a,1) >=0 && size(a,2) <= 1 && ndims(a)==2);
