% Q2_DELETE_WORKFOLDER   Deletes temporary a work folder
%
%   Removes a temporary folder created by *q2_create_workfolder*.
%
% FORMAT   q2_delete_workfolder( workfolder )
%        
% IN    workfolder   Temporary folder created by *q2_create_workfolder*.

% 2016-01-07   Patrick Eriksson.

function q2_delete_workfolder( workfolder )

% For extra safety, check that folder is placed in /tmp
%
if ~strcmp( workfolder(1:5), '/tmp/' )
  error( 'Folder to be removed must be placed in /tmp.' ); 
end

if exist( workfolder, 'dir' )
  [succ,msg] = rmdir( workfolder, 's' );
  if ~succ
    error( msg ); 
  end
else
  error( 'Given folder does not exist.' );
end
