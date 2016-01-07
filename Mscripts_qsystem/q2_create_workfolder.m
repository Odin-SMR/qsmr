% Q2_CREATE_WORKFOLDER   Creates or set the folder for temporary files
%
%   A folder is created if Q.FOLDER_WORK equals '/tmp'. Otherwise
%   *workfolder* is simply set to Q.FOLDER_WORK.
%
%   For automatic (and safest) removal of the work folder, add this in the
%   calling function
%      [workfolder,rm_wfolder] = q2_create_workfolder( Q );
%      if rm_wfolder
%        cu = onCleanup( @()q2_delete_workfolder( workfolder ) );
%      end
%
% FORMAT   [workfolder,rm_wfolder] = q2_create_workfolder(Q,R)
%        
% IN    Q            A Q structure.
% OUT   workfolder   The folder created or selected.
%       rm_wfolder   Boolean flagging if folder shall be removed or not.

% 2015-05-18   Patrick Eriksson.

function [workfolder,rm_wfolder] = q2_create_workfolder( Q )

% Operation mode: create a temporary folder
if strcmp( Q.FOLDER_WORK, '/tmp' )  |  strcmp( Q.FOLDER_WORK, '/tmp/' )
  %
  ready = false;
  count = 10;
  %
  while ~ready & count
    workfolder = tempname( Q.FOLDER_WORK );
    su = mkdir( workfolder );
    if su
      ready = true;
    else
      count = count - 1;
      if ~count
        error( 'Could not create a temporary work folder.' );
      end
    end
  end
  %
  rm_wfolder = true;
  

% Debugging mode: use given folder, and don't remove folder
else
  %
  workfolder = Q.FOLDER_WORK;
  rm_wfolder = false;
  
end

