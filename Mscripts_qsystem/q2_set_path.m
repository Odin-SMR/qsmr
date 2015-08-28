% Q2_SET_PATH   Adds the Qsmr mscript and setting folders to the search path.
%
%    This function should be called at startup. It does not return a
%    reporting string.
%
% FORMAT   q2_set_path

% 2015-05-18   Patrick Eriksson.

function q2_set_path

%- Check if Atmlab is ta hand
%
if ~exist( 'atmlab_init', 'file' )
  error( 'Atmlab must be at hand when calling this function.' );
end

topfolder = folder_of_fun( mfilename, 1 );
 
addpath( fullfile( topfolder, 'Settings' ) );
addpath( fullfile( topfolder, 'Mscripts_arts' ) );
addpath( fullfile( topfolder, 'Mscripts_database' ) );
addpath( fullfile( topfolder, 'Mscripts_external' ) );
addpath( fullfile( topfolder, 'Mscripts_qsystem' ) );


