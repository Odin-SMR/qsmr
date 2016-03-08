% Internal function to open an output file for writing.
%
%    On error, the execution is stopped and an error message is printed.
%
% FORMAT   fid = xmlOpenOutputFile(filename)
%
% OUT   fid        File descriptor
% IN    filename   XML filename
 
% 2002-12-13   Created by Oliver Lemke.

function fid = xmlOpenOutputFile(filename)

fid = fopen (filename,'w+t');

if fid == -1
  error (sprintf ('Cannot open file %s', filename));
end

