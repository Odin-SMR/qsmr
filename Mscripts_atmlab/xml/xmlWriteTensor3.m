% Writes a Tensor3 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor3(fid, fidb, data, precision)
%
% IN    fid   File descriptor
% IN    fidb       File descriptor for binary file
% IN    data  Tensor3
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor3(fid, fidb, data, precision, attrlist)

if nargin < 5
  attrlist = [];
end
  
s = size (data);

for i = (ndims (data)+1):3
  s(i) = 1;
end

np = s(1);
nr = s(2);
nc = s(3);

attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor3', attrlist);

data = permute (data, [3 2 1]);

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

xmlWriteCloseTag (fid, 'Tensor3');

