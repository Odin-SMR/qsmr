% FOLDER_OF_FUN   Folder containing a given function
%
%    The function returns the path of the folder where the specified function.
%    The function *which* is used to locate thefunction *funname*.
%
%    The optional argument *uplevels* can be used to directly move to some
%    parant folder.
%
% FORMAT folder = folder_of_fun( funname[, uplevels] )
%
% OUT   folder   Path of folder
% IN    funname  Name of function
% OPT   uplevels Move up this number of levels, to reach a parent folder.
%                Default is 0.

% 2014-08-29   Created by Patrick Eriksson

function folder = folder_of_fun( funname, uplevels )
%
if nargin == 1, uplevels = 0; end

folder = fileparts( which( funname ) );

for i = 1 : uplevels
  folder = fileparts( folder );
end