% Writes a GriddedField5 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGriddedField5(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       GriddedField5
% IN    precision  Precision for floats

% 2008-07-02   Created by Oliver Lemke.

function xmlWriteGriddedField5(fid, fidb, data, precision)

  xmlWriteGFieldWrapper (fid, fidb, data, precision, 5 );

