% Q2_INIT   Initialises the Qsmr system
%
%   The following operations are performed:
%     * Checks if Atmlab and Qsmr are part of Matlab's search path.
%     * If off-line, adds the additional folders needed.
%
%   It should suffice to call this function just once during a session.
%
%   Note that if this function is called with *online* set to false, Matlab
%   must be re-started to switch to "online". While switching from "online"
%   to "offline" can be done at a later stage, by calling this function with
%   *online* set to true followed by a new call of q2_init_r. 
%
% FORMAT   r = q2_init( [online] )
%        
% OUT   r        A report string. Empty if all OK. 
% OPT   online   Flag to indicate if an on-line run or not. Default is true.  

% 2015-05-18   Patrick Eriksson.

function r = q2_init ( online )
%
if nargin < 1, online = true; end
  
%- Init error reporting
%
r = [];
mfile = upper( mfilename );


%- Check if Atmlab is at hand
%
if ~exist( 'atmlab_init', 'file' )
  r = 'Atmlab must be added to the search path.';
  if nargout
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
end


%- Check if Qsmr itself is at hand
%
if ~exist( 'q_std', 'file' )
  r = 'Qsmr must be added to the search path.';
  if nargout
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
end


%- Extra folders if not online
%
if ~online
  topfolder = q2_topfolder;
  addpath( fullfile( topfolder, 'Mscripts_precalc' ) );
  addpath( fullfile( topfolder, 'Mscripts_offline' ) );
end


