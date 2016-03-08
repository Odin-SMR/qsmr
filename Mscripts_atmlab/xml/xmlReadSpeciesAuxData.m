% Reads SpeciesAuxData from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadSpeciesAuxData(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     SpeciesAuxData
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2015-06-24   Created by Oliver Lemke.

function result = xmlReadSpeciesAuxData(fid, attrlist, itype, ftype, binary, fid2)

ne = str2double (xmlGetAttrValue (attrlist, 'nelem'));
format = str2double (xmlGetAttrValue (attrlist, 'version'));

if format ~= 2
    error('atmlab:xmlReadSpeciesAuxData:UnsupportedVersion', ...
        'Unsupported SpeciesAuxData version');
end

result = cell(1, ne);
for i = 1:ne
    aux.artstag = xmlReadTag(fid, '', itype, ftype, binary, fid2);
    aux.auxtype = xmlReadTag(fid, '', itype, ftype, binary, fid2);
    aux.auxdata = xmlReadTag(fid, '', itype, ftype, binary, fid2);
    result{i} = aux;
    clear aux;
end
