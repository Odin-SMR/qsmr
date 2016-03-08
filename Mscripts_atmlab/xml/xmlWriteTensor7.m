% Writes a Tensor7 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor7(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Tensor7
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor7(fid, fidb, data, precision)

if nargin < 5
  attrlist = [];
end

s = size (data);

for i = (ndims (data)+1):7
  s(i) = 1;
end

nl = s(1);
nv = s(2);
ns = s(3);
nb = s(4);
np = s(5);
nr = s(6);
nc = s(7);

attrlist = xmlAddAttribute (attrlist, 'nlibraries', sprintf ('%d', nl));
attrlist = xmlAddAttribute (attrlist, 'nvitrines', sprintf ('%d', nv));
attrlist = xmlAddAttribute (attrlist, 'nshelves', sprintf ('%d', ns));
attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor7', attrlist);

data = permute (data, [7 6 5 4 3 2 1]);

if (strcmp(precision, 'BINARY'))
    fwrite (fidb, data, 'double');
else
    format=xmlGetPrecisionFormatString (precision);
    form=format;
    for i = 1:(nc-1)
        form = sprintf ('%s %s', form, format);
    end
    form = [form, '\n'];
    fprintf (fid, form, data);
end

xmlWriteCloseTag (fid, 'Tensor7');

