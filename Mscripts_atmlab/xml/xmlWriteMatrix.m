% Writes a Matrix to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteMatrix(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Matrix
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteMatrix(fid, fidb, data, precision, attrlist)

if nargin < 5
  attrlist = [];
end

s = size (data);

for i = (ndims (data)+1):2
  s(i) = 1;
end

nr = s(1);
nc = s(2);

attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Matrix', attrlist);

data = reshape (data, [nr nc]);
data = data';

if (strcmp(precision, 'BINARY'))
    fwrite (fidb, data, 'double');
else
    format=xmlGetPrecisionFormatString (precision);
    form=format;
    for i = 1:(nc-1)
      form = sprintf ('%s %s', form, format);
    end
    form = [form '\n'];

    fprintf (fid, form, data);
end

xmlWriteCloseTag (fid, 'Matrix');

clear attrlist form format nr nc;

