% Reads an abitrary array from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    The array can contain any kind of data. For ArrayOfArray the function
%    calls itself recursively.
%
% FORMAT   result = xmlReadArray(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Array
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-09-25   Created by Oliver Lemke.

function result = xmlReadArray(fid, attrlist, itype, ftype, binary, fid2)

ne = str2double (xmlGetAttrValue (attrlist, 'nelem'));
atype = xmlGetAttrValue (attrlist, 'type');
if length(atype) >= 5 && strcmp(atype(1:5), 'Array'), atype = 'Array'; end
result = {};
e = 0;
while e ~= ne
  e = e + 1;
  result{e} = xmlReadTag(fid, '', itype, ftype, binary, fid2, atype);
end
