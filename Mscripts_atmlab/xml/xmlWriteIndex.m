% Writes an Index to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteIndex(fid, fidb, data)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Index
% IN    precision  Precision for floats

% 2002-12-17  Created by Oliver Lemke.

function xmlWriteIndex(fid, fidb, data, precision)

xmlWriteTag (fid, 'Index', []);

if (strcmp(precision, 'BINARY'))
    fwrite (fidb, data, 'integer*4');
else
    fprintf (fid, '%d\n', data);
end

xmlWriteCloseTag (fid, 'Index');

