% VEC2COL   Ensures that a variable not has less rows than columns.
%
%    The most common application of this function is to ensure that a 
%    vector is a column vector.
%
% FORMAT   v = vec2col(v)
%        
% OUT   v   A variable of any type.
% IN    v   The variable possible transposed.

% 1993        Created by Patrick Eriksson. 
% 2002-12-10  Adapted to Atmlab from arts/ami.
% 2013-03-04  Bugfix by Gerrit Holl for empty vector + do not get conj

function v = vec2col(v)

[rows,cols] = size(v);


if cols > rows
  v = v.';
end

