% FILEOPEN   Open file with error message if not succesful.
%
%    This function calls *fopen* to open the given file, and gives an error
%    if the file could not be opened. This function saves you the trouble
%    of checking the file identified returned by *fopen*.
%
% FORMAT   See *fopen*.

% 2002-12-20   Created by Patrick Eriksson.
% 2012-05-24   Improved by Gerrit Holl.

function fid = fileopen(filename,varargin)


%= Call fopen
%
[fid, message] = fopen( filename, varargin{:} );


%= Was open succesful?
%
if fid < 0
  error(['atmlab:' mfilename ':IOError'], 'Could not open file %s: %s', filename, message );
end

end
