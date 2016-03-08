% WHICHFILES   Gives a list of files in a folder
%
%    The function returns all files in a folder that match some regular
%    search expression. 
%
%    Folders are ignored. This means that '*' will not include . and ..
%
%    See also *whichfiles*.
%
% FORMAT   filenames = whichfiles( [ rgexp, folder ] )
%        
% OUT   filenames   Cell array of strings with names of files. Complete path
%                   is given.
% OPT   rgexp       Search expression, such as '*.mat'. Default is '*'.
%       folder      Path to folder. If not given, pwd is used.

% 2006-02-01   Created by Patrick Eriksson.


function filenames = whichfiles( rgexp, folder )


if nargin < 1
  rgexp = '*';
end
if nargin < 2
  folder = pwd;
end


%= Search folder 
%
D = dir( fullfile( folder, rgexp ) );


%= Create filenames
%
filenames = [];  % If no files found
%
if ~isempty(D)
  j = 0;
  for i = 1:length(D)
    if ~D(i).isdir
      j = j + 1;
      filenames{j} = fullfile( folder, D(i).name );
    end
  end
end
 
