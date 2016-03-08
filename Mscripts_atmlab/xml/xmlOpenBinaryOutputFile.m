% Internal function to open a binary output file for writing.
%
%    On error, the execution is stopped and an error message is printed.
%
% FORMAT   fidb = xmlOpenBinaryOutputFile(filename)
%
% OUT   fidb        File descriptor
% IN    filename    XML filename
 
% 2002-12-13   Created by Oliver Lemke.

function fidb = xmlOpenOutputFile(filename)

filename = [filename '.bin'];
fidb = fopen (filename, 'w+', 'ieee-le');

if fidb == -1
  error (sprintf ('Cannot open file %s', filename));
end

