% Reads a GriddedField4 from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GriddedField4 structure.
%
% FORMAT   result = xmlReadGriddedField4(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     GriddedField4
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2004-02-20       Created by Oliver Lemke.

function result = xmlReadGriddedField4(fid, attrlist, itype, ftype, binary, fid2)

  result = xmlReadGFieldWrapper(fid, attrlist, itype, ftype, binary, fid2, 4);
