% Q2_PGRID   Creates pressure grids to be used in Qsmr2
%
%    This function ensures that fixed pressure levels are used in the
%    calculations. Both the forward model grid (P_GRID) and retrieval grids
%    are handled. 
%
%    The defualt grid spans roughly 0 to 150 km, with a spacing of about 500 m.
%
% FORMAT   p_grid = qs2_pgrid([ zmin, zmax, is_pgrid ] )
%    
% OUT   p_grid      Forward or retrieval pressure grid.
% OPT   zmin        Lower altitude limit. Default is 0 km (1000hPa)
%       zmax        Crop the grid above this geometrical altitude. Default
%                   is 150 km (5e-4Pa).
%       npd         Number of points per preessure decade. Default is 32.
%                   Accepted calues are 2, 4, 8, 16 and 32, where 32 should be
%                   used for P_GRID and 16 should be main option for
%                   retrieval grids.

% 2015-05-20   Created by Patrick Eriksson.


function p_grid = q2_pgrid( varargin )
%
[zmin,zmax,npd] = optargs( varargin, { 0, 150e3, 32 } );
%
assert( zmin >= 0 );
assert( zmax <= 150e3 );
assert( any( npd == [2,4,8,16,32] ) );


%- Start and end point of a complete grid with some margin on top
%
logp1  = 5;        % 1000 hPa
logp2  = -3.5;     % Somewhere above 150 km


%- Create the maximum grid
%
p_grid = 10.^[logp1:-1/npd:logp2]';


%- Crop with respect to zlow and zhigh
%
% Conversion from z to p done by table with approx values
P2Zapprox = [
   1.0000e+05            0
   5.1736e+04   5.2823e+03
   2.6766e+04   9.8251e+03
   1.3848e+04   1.4028e+04
   7.1643e+03   1.8166e+04
   3.7065e+03   2.2299e+04
   1.9176e+03   2.6525e+04
   9.9209e+02   3.0874e+04
   5.1327e+02   3.5417e+04
   2.6554e+02   4.0283e+04
   1.3738e+02   4.5494e+04
   7.1076e+01   5.0747e+04
   3.6772e+01   5.5750e+04
   1.9024e+01   6.0551e+04
   9.8425e+00   6.5155e+04
   5.0921e+00   6.9630e+04
   2.6344e+00   7.3970e+04
   1.3630e+00   7.8162e+04
   7.0514e-01   8.2213e+04
   3.6481e-01   8.6140e+04
   1.8874e-01   8.9926e+04
   9.7646e-02   9.3616e+04
   5.0518e-02   9.7245e+04
   2.6136e-02   1.0094e+05
   1.3522e-02   1.0494e+05
   6.9956e-03   1.0963e+05
   3.6193e-03   1.1561e+05
   1.8725e-03   1.2371e+05
   9.6874e-04   1.3472e+05
   5e-04           150e+03
];
%
plims  = exp( interp1( P2Zapprox(:,2), log(P2Zapprox(:,1)), [zmin,zmax] ) );
p_grid = p_grid( find( p_grid<=plims(1) & p_grid>=plims(2) ) );
