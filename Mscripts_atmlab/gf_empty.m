% GF_EMPTY   Creates an empty and minimal gformat structure
%
%    The returned structure has the minimal set of fields for the selected
%    dimensionality. All fields are set to be empty, except DIM that is set to
%    *dim* and TYPE that is set to 'basic'.
%
% FORMAT   G = gf_empty( [ dim ] )
%        
% OUT   G     Created gformat structure.
% OPT   dim   Dimensionality. Default is 0.

% 2010-01-06   Created by Patrick Eriksson.

function G = gf_empty( dim )
%
if nargin < 1  ||  isempty(dim)
  dim = 0;
end

G.TYPE      = 'basic';
G.NAME      = [];
G.SOURCE    = [];
G.DIM       = dim;
G.DATA      = [];
G.DATA_NAME = [];
G.DATA_UNIT = [];

for i = 1 : dim
  G = gf_set_grid( G, i, [], [], [] );
end


