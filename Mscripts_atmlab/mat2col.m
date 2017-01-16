% MAT2VEC   Converts a matrix to a column vector.
%
%    This is a function equivalent of a = A(:).
%
% FORMAT   a = mat2col(A)
%        
% OUT   a   A column vector
% IN    A   Data.

% 2006-08-31   Created by Patrick Eriksson.


function a = mat2col(A)

a = A(:);