% Reads a GridPos from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GridPos structure.
%
% FORMAT   result = xmlReadGridPos(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     GridPos
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-01-09   Created by Oliver Lemke.

function result = xmlReadGridPos(fid, attrlist, itype, ftype, binary, fid2)

  result.idx   = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  fd1 = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  fd2 = xmlReadTag(fid, '', itype, ftype, binary, fid2);

  result.fd = [fd1 fd2];

  clear fd1 fd2;
