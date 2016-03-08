% GF_REGRID   Change of rectangular grid for gformat data
%
%    Largely an interface to *gridinterp*. The dimension and size of new data
%    are determined by the number of grids and their lengths, respectively.
%
%   The interpolation is made as using *gridinterp* with its optional argument
%   *extrap* set to true. That is, the data are assumed to be defined
%   everywhere (end values valid all the way to +-INF). This is also valid for
%   singleton dimensions. The grid for empty/singleton dimensions can be empty
%   or a scalar.
%
%    The function is "vectorised". That is, can be called as
%      G(2:3) = gf_regrid( G(2:3), ...
%
% FORMAT   G = gf_regrid( G, grids, iopt )
%
% OUT   G      Re-grided gformat data.
% IN    G      Original gformat data.
%       grids  New grids. An array of vectors.
% OPT   iopt   Interpolation option. See *regrid*.
%

% 2007-10-17   Created by Patrick Eriksson.


function G = gf_regrid( G, grids, iopt )
%
if nargin < 3
  iopt = 'linear';
end


agrids = cell(length(G));
for i = 1 : length( G )
  %
  for d = 1  : G(i).DIM
      gname        = sprintf('GRID%d',d);
      agrids{d}    = G(i).(gname);
      G(i).(gname) = grids{d};
  end
  %
  G(i).DATA = gridinterp( agrids, G(i).DATA, grids, iopt, true );
  %
end