% ATMDATA_EMPTY   Creates an empty and minimal atmdata structure
%
%    The returned structure has the minimal set of fields for the selected
%    dimensionality. Most fields are set to be empty. Exceptions:
%
%       DIM is set to *dim* 
%
%       TYPE is set to 'atmdata'.
%    
%       Grid names and grid units are set as described in *isatmdata*,
%       beside GRID4_NAME that is set to '?'.
%
% FORMAT   G = atmdata_empty( [ dim ] )
%        
% OUT   G     Created atmlab structure.
% OPT   dim   Dimensionality. Default is 0. Max is 5.

% 2010-01-06   Created by Patrick Eriksson.

function G = atmdata_empty( dim )
%
if nargin < 1  |  isempty(dim)
  dim = 0;
end
 
G           = gf_empty( dim );
G.TYPE      = 'atmdata';

% If dim iswhole etc. is checked by gf_empty, but we need to check:
if atmlab('STRICT_ASSERT') & ( dim<0 | dim>5 )
  error( 'Input argument must be between 0 and 5.' );
end




% Any changes here must be described in header of *isatmdata* !!!
  
grid_names  = { 'Pressure', 'Latitude', 'Longitude', '?', 'Hour' };
grid_units  = { 'Pa', 'deg', 'deg', '', '' };

for d = 1 : dim
  G = gf_set_grid( G, d, [], grid_names{d}, grid_units{d} );
end

