% Writes a SpeciesTag to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   result = xmlWriteSpeciesTag(fid, fidb, data, precision)
%
% IN    fid        File descriptor of XML file
% IN    fidb       File descriptor for binary file
% IN    data       SpeciesTag
% IN    precision  Precision for floats

% 2002-12-17   Created by Oliver Lemke.

function result = xmlWriteSpeciesTag(fid, fidb, data, precision)

xmlWriteTag (fid, 'SpeciesTag', []);
fprintf (fid, '"%s"\n', data);
xmlWriteCloseTag (fid, 'SpeciesTag');

