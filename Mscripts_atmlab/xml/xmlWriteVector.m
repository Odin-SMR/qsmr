% Writes a Vector to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteVector(fid, fidb, data, precision, attrlist)
%
% IN    fid       File descriptor
% IN    fidb      File descriptor for binary file
% IN    data      Vector
% IN    precision Precision
% IN    attrlist  Attribute list
 
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteVector(fid, fidb, data, precision, attrlist)

if nargin < 5
  attrlist = [];
end

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 && ncols ~=0 && nrows ~= 1 && ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));

xmlWriteTag (fid, 'Vector', attrlist);

if (strcmp(precision, 'BINARY'))
    fwrite (fidb, data, 'double');
else
    fprintf (fid, [xmlGetPrecisionFormatString(precision) '\n'], data);
end

xmlWriteCloseTag (fid, 'Vector');

