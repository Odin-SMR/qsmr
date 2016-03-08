% Reads a RetrievalQuantity from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GriddedField3 structure.
%
% FORMAT   result = xmlReadRetrievalQuantity(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     RetrievalQuantity
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2005-05-30       Created by Mattias Ekstrom.

function result = xmlReadRetrievalQuantity(fid, attrlist, itype, ftype, binary, fid2)

  result.maintag      = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.subtag       = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.subsubtag    = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.mode         = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.analytical   = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.perturbation = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.grids        = xmlReadTag(fid, '', itype, ftype, binary, fid2);
