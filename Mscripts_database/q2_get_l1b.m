% Q2_GET_L1B   Extracts L1B data from central database
%
%   The function performs the basic reading, as well as performing some
%   basic checks of the data.
%
% FORMAT   L1B = q2_get_l1b( LOG )
%
% OUT  L1B   L1B structure.
% IN   LOG   Log data of a single scan.

% 2015-12-18   Created by Patrick Eriksson.


function L1B = q2_get_l1b( LOG )
%
if length(LOG) > 1
  error( 'This function handles only single logdata entries.' );
end

% Read the data
L1B = get_scan_l1b_data( LOG.URL ); 


% Temporary fix
%
L1B.HANNING = ones( 1, length( L1B.Altitude ) );


% Basic checks
%
if unique( L1B.FreqMode ) > 1
  error( 'The L1B data can just contain a single frequency mode.' );
end