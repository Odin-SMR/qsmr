% SYMGRID   Creates a grid that is symmetric around zero
%
%    The function "mirrors" an existing grid around zero, and append the two
%    grids. The original grid must contain positive values. Zero can be
%    included (will not be repeated). The output is sorted in ascending order.
%
% FORMAT   g = symgrid(g)
%        
% OUT   g   Extended grid
% IN    g   Positive side of grid. Can include the value zero.

% 2007-11-29   Created by Patrick Eriksson.


function g = symgrid(g)
  
if ~isnumeric(g) | ~isvector(g)
  error( 'Input variable *g* must be a vector.' );
end

if any( g < 0 )
  error( 'Input variable *g* can not contain negative values.' );
end


g = sort(g);

if g(1) == 0
  g = g([end:-1:2 1:end]);
else
  g = g([end:-1:1 1:end]);
end


%- Make first part negative
%
[u,i] = min(g);
%
g(1:i) = -g(1:i);