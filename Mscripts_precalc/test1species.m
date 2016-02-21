% TEST1SPECIES   Test impact of species in a band
%
%   This is a simple help function to estimate impact of a species on a
%   frequency mode. Pencil beam spectra are calculated for given tangent
%   altitudes, latitude and DOY. Only the primary band is considered and
%   only transitions relatively close to the band are considered (see
%   q2_arts_y for range included). 
%
% FORMAT [F,Y] = test1species( ztans, lat, doy, fmode, species )
%
% OUT   F   Frequencies matching Y
%       Y   Simulated spectra.
% IN    ztans    Vector with tangent altitudes
%       lat      Latitude
%       doy      Day of the year
%       fmode    Frequency mode
%       species  Species tag string, e.g. 'O3-668'

% 2016-02-20   Patrick Eriksson

function [F,Y] = test1species( ztans, lat, doy, fmode, species )

Q = q_std( fmode );

Q.ABS_SPECIES             = [];
Q.ABS_SPECIES(1).TAG{1}   = species;
Q.ABS_SPECIES(1).SOURCE   = 'Bdx';
Q.ABS_SPECIES(1).RETRIEVE = false;


[LOG,L1B] = l1b_homemade( Q, ztans, lat, 0, date2mjd(2010,1,1)+doy );


ATM = q2_get_atm( LOG, Q );


[Y,F] = q2_arts_y( L1B, ATM, Q, false, false );

plot( F/1e9, Y, '.' )
xlabel( 'Frequency [GHz]' );
ylabel( 'Tb [K]' );