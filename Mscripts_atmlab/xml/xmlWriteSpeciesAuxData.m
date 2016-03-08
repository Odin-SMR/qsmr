% Writes a SpeciesAuxData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSpeciesAuxData(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Ppath
% IN    precision  Precision for floats

% 2015-06-24  Created by Oliver Lemke.

function xmlWriteSpeciesAuxData(fid, fidb, data, precision)

attrlist = [];
attrlist = xmlAddAttribute(attrlist, 'version', '2');
attrlist = xmlAddAttribute(attrlist, 'nelem', sprintf ('%d', numel(data)));
xmlWriteTag (fid, 'SpeciesAuxData', attrlist);

for i = 1:numel(data)
    xmlWriteString (fid, fidb, data{i}.artstag, precision);
    auxtype = data{i}.auxtype;
    if ~strcmp(auxtype, 'NONE') ...
            && ~strcmp(auxtype, 'ISORATIO') ...
            && ~strcmp(auxtype, 'ISOQUANTUM') ...
            && ~strcmp(auxtype, 'PART_TFIELD') ...
            && ~strcmp(auxtype, 'PART_COEFF') ...
            && ~strcmp(auxtype, 'PART_COEFF_VIBROT')
        error('atmlab:xmlWriteSpeciesAuxData:UnknownAuxType', ...
            'AuxType must be one of: NONE, ISORATIO, ISOQUANTUM, PART_TFIELD, PART_COEFF, PART_COEFF_VIBROT');
    end
    xmlWriteString (fid, fidb, data{i}.auxtype, precision);
    xmlWriteArrayOf (fid, fidb, data{i}.auxdata, 'GriddedField1', precision);
end

xmlWriteCloseTag (fid, 'SpeciesAuxData');
