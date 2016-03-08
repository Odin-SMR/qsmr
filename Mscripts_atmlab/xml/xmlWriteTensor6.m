% Writes a Tensor6 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor6(fid, fidb, data, precision)
%
% IN    fid    File descriptor
% IN    fidb       File descriptor for binary file
% IN    data   Tensor6
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor6(fid, fidb, data, precision, attrlist)

if nargin < 5
  attrlist = [];
end

s = size (data);

for i = (ndims (data)+1):6
  s(i) = 1;
end

nv = s(1);
ns = s(2);
nb = s(3);
np = s(4);
nr = s(5);
nc = s(6);

attrlist = xmlAddAttribute (attrlist, 'nvitrines', sprintf ('%d', nv));
attrlist = xmlAddAttribute (attrlist, 'nshelves', sprintf ('%d', ns));
attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor6', attrlist);

data = permute (data, [6 5 4 3 2 1]);

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

xmlWriteCloseTag (fid, 'Tensor6');

