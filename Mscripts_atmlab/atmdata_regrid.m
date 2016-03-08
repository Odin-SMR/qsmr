% ATMDATA_REGRID   Change of rectangular grid for atmdata
%
%    Largely an interface to *gf_regrid*, but ensures that the atmdata format
%    is followed and that pressure grids are converted to log(p).
%
%    If *grids* covers the day dimension (fourth dimension), the day(s) shall
%    be given as MJD. These dates are translated to the date format used in
%    *G* by the function. If *G* is an array, the same time format is assumed
%    for all elements.
%
% FORMAT   G = atmdata_regrid( G, grids [, nonstdname] )
%
% OUT   G            Re-grided atmlab data.
% IN    G            Original atmlab data.
%       grids        New grids. An array of vectors.
% OPT   nonstdname   Name of *G* to use in error message. Default is
%                    to use the function *inputname* to determine the
%                    variable name.

% 2007-10-17   Created by Patrick Eriksson.


function G = atmdata_regrid( G, grids, nonstdname )



%- Take log of pressure
%
if ~isempty( grids )
  g0       = grids{1};
  grids{1} = -log( grids{1} );
end
for i = 1 : length(G)
  if G(i).DIM > 0
    G(i).GRID1 = -log( G(i).GRID1 );
  end
end


%- Handle day formats
%
if length(grids) >= 4
    
    % Trigger warning if doy or datenum (with std. pivot year) are used
    if min(grids{4}) < 370 ||  max(grids{4}) > 250e3
      warning(['atmlab:' mfilename], ...
          'Suspicious day data found! Dates (in *grids*) should use MJD.')
    end


  [maxdim,i] = max( [G.DIM] );
  if maxdim >= 4
    tformat = lower( G(i).GRID4_NAME );
    if strcmp( tformat, 'mjd' )
      %
    elseif strcmp( tformat, 'doy' )
      grids{4} = mjd2doy( grids{4} );
    elseif strcmp( tformat, 'datenum' )
      [ye,mo,da,ho,mi,se] = mjd2date( grids{4} );
      grids{4} = datenum( ye, mo, da, ho, mi, se );
    else 
      assert( false );
    end 
  end
end

G = gf_regrid( G, grids );

% Restore pressure grid
%
for i = 1 : length(G)
  if G(i).DIM > 0
    G(i).GRID1 = g0;
  end
end
