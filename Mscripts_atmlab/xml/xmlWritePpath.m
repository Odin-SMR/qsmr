% Writes a Ppath to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWritePpath(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Ppath
% IN    precision  Precision for floats

% 2003-01-09  Created by Oliver Lemke.

function xmlWritePpath(fid, fidb, data, precision)

xmlWriteTag (fid, 'Ppath', []);

xmlWriteIndex (fid, fidb, data.dim, precision);
xmlWriteIndex (fid, fidb, data.np, precision);
xmlWriteNumeric (fid, fidb, data.constant, precision);
xmlWriteString (fid, fidb, data.background, precision);
xmlWriteVector (fid, fidb, data.start_pos, precision);
xmlWriteVector (fid, fidb, data.start_los, precision);
xmlWriteNumeric (fid, fidb, data.start_lstep, precision);
xmlWriteMatrix (fid, fidb, data.pos, precision);
xmlWriteMatrix (fid, fidb, data.los, precision);
xmlWriteVector (fid, fidb, data.r, precision);
xmlWriteVector (fid, fidb, data.lstep, precision);
xmlWriteVector (fid, fidb, data.end_pos, precision);
xmlWriteVector (fid, fidb, data.end_los, precision);
xmlWriteNumeric (fid, fidb, data.end_lstep, precision);
xmlWriteVector (fid, fidb, data.nreal, precision);
xmlWriteVector (fid, fidb, data.ngroup, precision);
xmlWriteArrayOf (fid, fidb, data.gp_p, 'GridPos', precision);
xmlWriteArrayOf (fid, fidb, data.gp_lat, 'GridPos', precision);
xmlWriteArrayOf (fid, fidb, data.gp_lon, 'GridPos', precision);

xmlWriteCloseTag (fid, 'Ppath');

