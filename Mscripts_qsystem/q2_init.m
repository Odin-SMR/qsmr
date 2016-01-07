% Q2_INIT   Initialises the Qsmr system
%
%   The following operations are performed:
%     * Adds Qsmr to the search path
%     * Checks if ARTS is found and expected version is used
%
%   It should suffice to call this function just once during a session.
%
% FORMAT   q2_init

% 2015-12-17   Patrick Eriksson.

function q2_init


%- Add Qsmr itself to search path
%
topfolder = fileparts( fileparts( which( mfilename ) ) );
%
addpath( fullfile( topfolder, 'Settings' ) );
addpath( fullfile( topfolder, 'Mscripts_arts' ) );
addpath( fullfile( topfolder, 'Mscripts_database' ) );
addpath( fullfile( topfolder, 'Mscripts_external' ) );
addpath( fullfile( topfolder, 'Mscripts_qsystem' ) );
addpath( fullfile( topfolder, 'Mscripts_precalc' ) );
addpath( fullfile( topfolder, 'Mscripts_webapi' ) );

  
  


%- Check ARTS
%
% Add checks of ARTS here

