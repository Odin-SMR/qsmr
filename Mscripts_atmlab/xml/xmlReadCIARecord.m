% Reads a CIARecord from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the CIARecord structure.
%
% FORMAT   result = xmlReadCIARecord(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     CIARecord
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-01-09   Created by Oliver Lemke.

function result = xmlReadCIARecord(fid, attrlist, itype, ftype, binary, fid2)

  if (~isequal(size(attrlist), [2, 2]))
    error('atmlab:xmlReadCIARecord', ...
          'Wrong number of attributes in CIARecord tag. Should be 2.');
  end

  result.molecule1 = attrlist{1, 2};
  result.molecule2 = attrlist{2, 2};
  result.data = xmlReadTag(fid, '', itype, ftype, binary, fid2);

