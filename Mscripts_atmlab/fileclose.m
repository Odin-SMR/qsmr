% FILECLOSE   Close file with error message if not succesful.
%
%    This function calls *fclose* to close the given file, and gives an error
%    if the file could not be opened. 
%
% FORMAT   See *fclose*.

% 2002-12-20   Created by Patrick Eriksson.


function st = fileclose(fid)


%= Call fclose
%
st = fclose( fid );


%= Was close succesful?
%
if st < 0
  serr = sprintf( 'Could not close the file %s.', filename );
  error( serr );
end