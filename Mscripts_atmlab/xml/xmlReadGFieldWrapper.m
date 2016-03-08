% Reads a GField from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GField structure.
%
% FORMAT   result = xmlReadGFieldWrapper(fid, attrlist, itype, ftype, binary, fid2, dim)
%
% OUT   result     GField
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file
% IN    dim        Dimension of the GField to read

% 2008-07-02       Created by Oliver Lemke.

function result = xmlReadGFieldWrapper(fid, attrlist, itype, ftype, binary, fid2, dim)

  result.name = xmlGetAttrValue (attrlist, 'name');

  for i = 1:dim
    [result.grids{i}, attr] = xmlReadTag(fid, '', itype, ftype, binary, fid2);
    result.gridnames{i} = xmlGetAttrValue (attr, 'name');
  end

  [result.data, attr]    = xmlReadTag(fid, '', itype, ftype, binary, fid2);
  result.dataname = xmlGetAttrValue (attr, 'name');

