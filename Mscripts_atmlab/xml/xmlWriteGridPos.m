% Writes a GridPos to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGridPos(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       GridPos
% IN    precision  Precision for floats

% 2003-01-09  Created by Oliver Lemke.

function xmlWriteGridPos(fid, fidb, data, precision)

xmlWriteTag (fid, 'GridPos', []);

xmlWriteIndex (fid, fidb, data.idx, precision);
xmlWriteNumeric (fid, fidb, data.fd(1), precision);
xmlWriteNumeric (fid, fidb, data.fd(2), precision);

xmlWriteCloseTag (fid, 'GridPos');

