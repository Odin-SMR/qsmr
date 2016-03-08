% Reads a Sparse from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadSparse(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Sparse
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-06-16  Created by Mattias Ekström.

function result = xmlReadSparse(fid, attrlist, itype, ftype, binary, fid2)

nr = str2double (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2double (xmlGetAttrValue (attrlist, 'ncols'));

i = xmlReadTag(fid, '', itype, ftype, binary, fid2);
j = xmlReadTag(fid, '', itype, ftype, binary, fid2);
s = xmlReadTag(fid, '', itype, ftype, binary, fid2);

i = i + 1;
j = j + 1;

xmlCheckSize (size (i), size (j));
xmlCheckSize (size (j), size (s));

result = sparse (i, j, s, nr, nc, size (s, 1));

