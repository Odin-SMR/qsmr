% GRIDDEDFIELD2GF   CREATES A STANDARD GFORMAT OF A GRIDDED FIELD
%
%   Takes in a arts GriddedField format and creates a Gformat 
%   structure of it. 
%
% NOTE: To import directly from an xml file use gf_artsxml instead
%
% FORMAT   G = griddedfield2gf( GF [, name, type ] )
%        
% OUT   G       Gformat structure
% IN    GF      Arts GriddedField structure
% OPT   name    Name of data. Will replace with is read from file if not
%               empty. Default is [].
%       type    Type of data. Default is []. Recognised options are
%                  'vmr_field' : volume mixing ratio field
%                  't_field'   : temperature (atmospheric) field
%                  'z_field'   : altitude (atmospheric) field
%                  'mag_field' : magnetic  field
%                  'wind_field': wind field

% 2011-02-09   Created by Ole Martin Christensen.

function G = griddedfield2gf( GF, name, type )
%
if nargin < 2, name = []; end
if nargin < 3, type = []; end
  

G = gf2gf_sub( GF, name, type );

return



% This stuff in sub-function due to historical reasons:
function G = gf2gf_sub( X, name, type )

%- Add user provided data (using some "false" fields)
%
if ~isempty( name )
  X.name = name;
end
%
if isempty( type )
  T.TYPE       = 'unknown';
  T.gridnames  = { [], [], [], [], [], [], [], [] };
  T.GRIDUNITS  = { [], [], [], [], [], [], [], [] };
  T.dataname   = [];
  T.DATAUNIT   = [];
elseif strcmpi( type, 'vmr_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'Volume mixing ratio';
  T.DATAUNIT   = '-';
elseif strcmpi( type, 't_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'Temperature';
  T.DATAUNIT   = 'K';
elseif strcmpi( type, 'z_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'Altitude';
  T.DATAUNIT   = 'm';
elseif strcmpi( type, 'mag_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'a magnetic component';
  T.DATAUNIT   = 'T';
elseif strcmpi( type, 'wind_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'A wind component';
  T.DATAUNIT   = 'm/s';
else 
  error( ['atmlab:' mfilename], ' Unknown selection for *type*.' ); 
end

%- Transfer to G (set only up to max "active" dimension)
%
G.TYPE      = T.TYPE;
G.NAME      = X.name;
%
G.DIM       = max( find( size(X.data) > 1 ) );
G.DATA      = X.data;
if isempty( X.dataname )
  G.DATA_NAME = T.dataname;
else
  G.DATA_NAME = X.dataname;
end
G.DATA_UNIT = T.DATAUNIT;
%
for d = 1 : G.DIM
  if length(X.gridnames) < d  ||  isempty( X.gridnames{d} )
    G = gf_set_grid( G, d, vec2col(X.grids{d}), T.gridnames{d}, ...
                                                             T.GRIDUNITS{d} );
  else    
    G = gf_set_grid( G, d, vec2col(X.grids{d}), X.gridnames{d}, ...
                                                             T.GRIDUNITS{d} );
  end
end

return