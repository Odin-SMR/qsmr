% Writes a RetrievalQuantity to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteRetrievalQuantity(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       RetrievalQuantity
% IN    precision  Precision for floats

% 2005-05-30   Created by Mattias Ekstrom.

function xmlWriteRetrievalQuantity(fid, fidb, data, precision)

xmlWriteTag (fid, 'RetrievalQuantity', []);

xmlWriteString (fid, fidb, data.maintag, precision);
xmlWriteString (fid, fidb, data.subtag, precision);
xmlWriteString (fid, fidb, data.subsubtag, precision);
xmlWriteString (fid, fidb, data.mode, precision);
xmlWriteIndex (fid, fidb, data.analytical, precision);
xmlWriteNumeric (fid, fidb, data.perturbation, precision);
xmlWriteArrayOf (fid, fidb, data.grids, 'Vector', precision);

xmlWriteCloseTag (fid, 'RetrievalQuantity');

