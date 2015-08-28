% Q2_CREATE_WORKFOLDER   Creates the temporary work folder to be used
%
%   A new work folder is created and R.WORK_FOLDER is set to its path.
%
%   The input R is not allowed to already hold a work folder.
%
%   For automatic (and safest) removal of the work folder, add this to the
%   top function
%     cu = onCleanup( @()delete_tmpfolder( R.WORK_FOLDER ) );
%
% FORMAT   [R,r] = q2_create_workfolder(Q,R)
%        
% IN    Q   A Q structure.
%       R   Original R structure.
% OUT   R   Modified R structure.
%       r   A report string. Empty if all OK.

% 2015-05-18   Patrick Eriksson.

function [R,r] = q2_create_workfolder(Q,R)

  
%- Init error reporting
%
r = [];
mfile = upper( mfilename );


%- R can not already contain WORK_FOLDER
%
if isfield( R, 'WORK_FOLDER' )
  r = 'R holds already a WORK_FOLDER.';
  if nargout > 1
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
end


%- Is WORK_AREA set correctly?
%
if ~exist( Q.WORK_AREA, 'dir' )
  r = 'WORK_AREA is not a valid/existing folder.';
  if nargout > 1
    r = sprintf( '%s: %s', mfile, r );
    return;
  else
    error( r );
  end
end


%- Create a temporary folder
%
atmlab( 'WORK_AREA', Q.WORK_AREA ); 
R.WORK_FOLDER = create_tmpfolder;

