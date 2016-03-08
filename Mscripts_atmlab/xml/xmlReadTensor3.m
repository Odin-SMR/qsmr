% Reads a Tensor3 from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadTensor3(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Tensor3
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-10-18   Created by Oliver Lemke.

function result = xmlReadTensor3(fid, attrlist, itype, ftype, binary, fid2)

np = str2double (xmlGetAttrValue (attrlist, 'npages'));
nr = str2double (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2double (xmlGetAttrValue (attrlist, 'ncols'));
nelem =  np * nr * nc;

if ~binary
  result = fscanf (fid, '%f', nelem);
else
  result = fread (fid2, nelem, ftype);
end
xmlCheckSize (nelem, size (result));

result = permute (reshape (result, [nc nr np]), [3 2 1]);

