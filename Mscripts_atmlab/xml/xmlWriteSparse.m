% Writes a Sparse to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSparse(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Sparse
% IN    precision  Precision for floats

% 2003-06-16  Created by Mattias Ekström.

function xmlWriteSparse(fid, fidb, data, precision)

s = size (data);

nr = s(1);
nc = s(2);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Sparse', attrlist);

[r,c] = find (data);

xmlWriteRowIndex (fid, fidb, r - 1, precision);
xmlWriteColIndex (fid, fidb, c - 1, precision);
xmlWriteSparseData (fid, fidb, nonzeros(data), precision);

xmlWriteCloseTag (fid, 'Sparse');

