% Q2_PGRID   Creates pressure grids to be used in Qsmr2
%
%    This function ensures that fixed pressure levels are used in the
%    calculations. Both the forward model grid (P_GRID) and retrieval grids
%    are handled. 
%
%    The defualt grid spans roughly 0 to 144 km. With is_pgrid = true, the
%    spacing is in the order of 200 m , while for retrieval grids it is
%    about 1.6 km. 
%
% FORMAT   p_grid = qs2_pgrid([ zmin, zmax, is_pgrid ] )
%    
% OUT   p_grid      Forward or retrieval pressure grid.
% OPT   zmin        Lower altitude limit. Default is no cropping at all at 
%                   high pressure end.
%       zmax        Crop the grid above this geometrical altitude. Default is
%                   is no cropping.
%       is_pgrid    Set to true if a p_grid shall be created. False is default,
%                   which equals to create a retrieval grid.
%       
% 2015-05-20   Created by Patrick Eriksson.


function p_grid = q2_pgrid( varargin )
%
[zmin,zmax,is_pgrid] = optargs( varargin, { 0, 150e3, false } );


%- Start and end point of complete grid:
%
%  If logp1 and logp2 are set to integer values, every integer pressure
%  decade is included in the grid (100, 10, 1 ... hPa).
%
logp1  =  5;    % 1000 hPa
logp2  = -4;    % About 144 km


%- Spacing of grid
%
% npd = number per pressure decade
%
% To avoid representation problems in the mapping between grids, 
% the npd for p_grid should be an integer times the npd for retrieval grids,
% such as 80 and 10, respectively.
%
if is_pgrid  
  npd = 80;    % Value for p_grid, with npd=80 spacing is about 200 m
else
  npd = 10;    % Value for retrieval grids, with npd=10 spacing is about 1.6 km
end
%
p_grid = logspace( logp1, logp2, 1+(logp1-logp2)*npd )';


%- Crop with respect to zlow and zhigh
%
p_grid = p_grid( find( p_grid<=z2p_simple(zmin) & p_grid>=z2p_simple(zmax) ) );
