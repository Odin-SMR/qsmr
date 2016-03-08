% Writes an ArrayOfArray to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteArrayOfArrayOf(fid, fidb, data, type, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Vector
% IN    type       Data type as string
% IN    precision  Precision for floats

% 2002-12-16  Created by Oliver Lemke.

function xmlWriteArrayOfArrayOf(fid, fidb, data, type, precision)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 && ncols ~=0 && nrows ~= 1 && ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

attrlist = xmlAddAttribute ([], 'type', sprintf ('ArrayOf%s', type));
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
for i = 1:nelem
  xmlWriteArrayOf (fid, fidb, data{i}, type, precision);
end

xmlWriteCloseTag (fid, 'Array');

