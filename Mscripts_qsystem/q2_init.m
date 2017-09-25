% Q2_INIT   Initialises qsmr
%
%   The following operations are performed:
%     * Adds qsmr folders to the search path
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
addpath( fullfile( topfolder, 'Mscripts_arts' ) );
addpath( fullfile( topfolder, 'Mscripts_atmlab' ) );
addpath( fullfile( topfolder, 'Mscripts_atmlab', 'xml' ) );
addpath( fullfile( topfolder, 'Mscripts_atmlab', 'time' ) );
addpath( fullfile( topfolder, 'Mscripts_database' ) );
addpath( fullfile( topfolder, 'Mscripts_misc' ) );
addpath( fullfile( topfolder, 'Mscripts_qsystem' ) );
addpath( fullfile( topfolder, 'Mscripts_webapi' ) );

  
  

