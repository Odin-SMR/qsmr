% Q2_INIT   Initialises the Qsmr system
%
%   The following operations are performed:
%     * Checks if Atmlab and Qsmr are part of Matlab's search path.
%     * Adds folder information to R
%
%   It should suffice to call this function just once during a session.
%
% FORMAT   R = q2_init
%        
% OUT   R   A start to a R structure.

% 2015-12-17   Patrick Eriksson.

function R = q2_init


%- Check if Atmlab is at hand
%
if ~exist( 'atmlab_init', 'file' )
  error( 'It seems that Atmlab is not added to the search path.' );
end


%- Check if Qsmr itself is at hand
%
if ~exist( 'q_std', 'file' )
  error( 'It seems that Qsmr is not added to the search path.' );
end


%- Init R by setting path to settings folder 
%
topfolder = folder_of_fun( mfilename, 1 );
%
R.FOLDER_SETTINGS = fullfile( topfolder, 'Settings' );

