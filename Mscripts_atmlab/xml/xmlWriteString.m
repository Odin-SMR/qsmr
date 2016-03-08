% Writes a String to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   result = xmlWriteString(fid, fidb, data, precision)
%
% IN    fid    File descriptor of XML file
% IN    fidb       File descriptor for binary file
% IN    data   String
% IN    precision  Precision for floats

% 2003-01-09   Created by Oliver Lemke.

function result = xmlWriteString(fid, fidb, data, precision)

xmlWriteTag (fid, 'String', []);
fprintf (fid, '"%s"\n', data);
xmlWriteCloseTag (fid, 'String');

