% Q2_INIT_R   Initialises the R structure
%
%   The following operations are performed:
%     * Adds folder information to R
%     * Sets R.ONLINE (in automatic fashion)
%
%   It should suffice to call this function just once during a session (as
%   long as you keep the *R* returned.
%
% FORMAT   R = q2_init_r
%        
% OUT   R   A start to a R structure.

% 2015-05-18   Patrick Eriksson.

function R = q2_init_r


%- Add path to settings folder
%
topfolder = folder_of_fun( mfilename, 1 );
%
R.FOLDER_SETTINGS = fullfile( topfolder, 'Settings' );


%- Online?
%
p = path;
%
if isempty( strfind( p, 'Mscripts_precalc' ) )
  R.ONLINE = true;
else
  R.ONLINE = false;
end  


