% Reads a Numeric from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadNumeric(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Numeric
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-12-13   Created by Oliver Lemke.

function result = xmlReadNumeric(fid, attrlist, itype, ftype, binary, fid2)

if ~binary
  result = fscanf (fid, '%f', 1);
else
  result = fread (fid2, 1, ftype);
end

