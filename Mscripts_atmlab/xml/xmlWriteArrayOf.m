% Writes an Array to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteArrayOf(fid, fidb, data, type, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Array
% IN    type       Data type as string
% IN    precision  Precision for floats
% IN    attrlist   Attribute list

% 2002-12-16  Created by Oliver Lemke.

function xmlWriteArrayOf(fid, fidb, data, type, precision, attrlist)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 && ncols ~=0 && nrows ~= 1 && ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

if (nargin < 6)
  attrlist = [];
end
attrlist = xmlAddAttribute (attrlist, 'type', type);
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
func = str2func (['xmlWrite' type]);
for i = 1:nelem
  feval (func, fid, fidb, data{i}, precision);
end
xmlWriteCloseTag (fid, 'Array');

