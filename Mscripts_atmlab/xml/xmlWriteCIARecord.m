% Writes a CIARecord to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteCIARecord(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       CIARecord
% IN    precision  Precision for floats

% 2013-02-07  Created by Oliver Lemke.

function xmlWriteCIARecord(fid, fidb, data, precision)

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'molecule1', data.molecule1);
attrlist = xmlAddAttribute (attrlist, 'molecule2', data.molecule2);

xmlWriteTag (fid, 'CIARecord', attrlist);

xmlWriteArrayOf(fid, fidb, data.data, 'GriddedField2', precision);

xmlWriteCloseTag (fid, 'CIARecord');

