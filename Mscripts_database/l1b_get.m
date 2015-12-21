% L1B_GET   Extracts L1B data from central database
%
%   The function performs the basic reading, as well as performing some
%   basic checks of the data.
%
% FORMAT   L1B = l1b_get( LOG )
%
% OUT  L1B   L1B structure.
% IN   LOG   Log data of a single scan.

% 2015-12-18   Created by Patrick Eriksson.


function L1B = l1b_get( LOG )
%
if length(LOG) > 1
  error( 'This function handles only single logdata entries.' );
end

% Read the data
L1B = get_scan_l1b_data( LOG.URL ); 


% Temporary fix
%
L1B.Hanning = ones( 1, length( L1B.Altitude ) );
