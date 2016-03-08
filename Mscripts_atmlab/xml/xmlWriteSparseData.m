% Writes SparseData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSparseData(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       SparseData
% IN    precision  Precision for floats

% 2003-06-18  Created by Oliver Lemke.

function xmlWriteSparseData(fid, fidb, data, precision)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 && ncols ~=0 && nrows ~= 1 && ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

xmlWriteTag (fid, 'SparseData', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

if (strcmp(precision, 'BINARY'))
    fwrite (fidb, data, 'double');
else
    fprintf (fid, [xmlGetPrecisionFormatString(precision) '\n'], data);
end

xmlWriteCloseTag (fid, 'SparseData');

