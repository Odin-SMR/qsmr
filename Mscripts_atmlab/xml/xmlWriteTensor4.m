% Writes a Tensor4 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor4(fid, fidb, data, precision)
%
% IN    fid    File descriptor
% IN    fidb       File descriptor for binary file
% IN    data   Tensor4
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor4(fid, fidb, data, precision, attrlist)

if nargin < 5
  attrlist = [];
end
  
s = size (data);

for i = (ndims (data)+1):4
  s(i) = 1;
end

nb = s(1);
np = s(2);
nr = s(3);
nc = s(4);

attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor4', attrlist);

data = permute (data, [4 3 2 1]);

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

xmlWriteCloseTag (fid, 'Tensor4');

