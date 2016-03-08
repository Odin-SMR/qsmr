% Reads a vector of Index from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT  result = xmlReadIndexVector(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Index Vector
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-06-18   Created by Oliver Lemke.

function result = xmlReadIndexVector(fid, attrlist, itype, ftype, binary, fid2)

nr = str2double (xmlGetAttrValue (attrlist, 'nelem'));

if ~binary
  result = fscanf (fid, '%d', nr);
else
  result = fread (fid2, nr, itype);
end
xmlCheckSize (nr, size (result));

