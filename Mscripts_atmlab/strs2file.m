% STRS2FILE   Prints a string array to a file.
%
%    The function creates an ASCII file and puts each item of *S* as
%    row into the file. That is, S{3} becomes row 3 of the file.
%
% FORMAT   strs2file( filename, S )
%        
% IN    filename   Name of file to create.
%       S          Cell array of strings. 

% 2010-01-12   Created by Patrick Eriksson.


function strs2file( filename, S )


%= Open file for writing
%
fid = fileopen( filename, 'w' );


%= Loop and write lines
%
for i = 1 : length(S)
  fprintf( fid, '%s\n', S{i} );
end


%= Close file
%
fid = fileclose( fid );