% Writes a Numeric to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteNumeric(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Numeric
% IN    precision  Precision for floats

% 2002-12-17  Created by Oliver Lemke.

function xmlWriteNumeric(fid, fidb, data, precision)

xmlWriteTag (fid, 'Numeric', []);

if (strcmp(precision, 'BINARY'))
    fwrite (fidb, data, 'double');
else
    fprintf (fid, [xmlGetPrecisionFormatString(precision) '\n'], data);
end

xmlWriteCloseTag (fid, 'Numeric');

