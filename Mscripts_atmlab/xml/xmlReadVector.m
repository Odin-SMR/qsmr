% Reads a Vector from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadVector(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Vector
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-11-14   Created by Oliver Lemke.

function result = xmlReadVector(fid, attrlist, itype, ftype, binary, fid2)

nr = str2double (xmlGetAttrValue (attrlist, 'nelem'));

if ~binary
  result = fscanf (fid, '%f', nr);
else
  result = fread (fid2, nr, ftype);
end
xmlCheckSize (nr, size (result));

