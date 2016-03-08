% Writes a GasAbsLookup table to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGasAbsLookup(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       GasAbsLookup table
% IN    precision  Precision for floats

% 2002-12-16  Created by Oliver Lemke.

function xmlWriteGasAbsLookup(fid, fidb, data, precision)

xmlWriteTag (fid, 'GasAbsLookup', []);

xmlWriteArrayOfArrayOf (fid, fidb, data.species, 'SpeciesTag', precision);
xmlWriteArrayOf (fid, fidb, data.nonlinear_species, 'Index', precision);
xmlWriteVector (fid, fidb, data.f_grid, precision);
xmlWriteVector (fid, fidb, data.p_grid, precision);
xmlWriteMatrix (fid, fidb, data.vmrs_ref, precision);
xmlWriteVector (fid, fidb, data.t_ref, precision);
xmlWriteVector (fid, fidb, data.t_pert, precision);
xmlWriteVector (fid, fidb, data.nls_pert, precision);
xmlWriteTensor4 (fid, fidb, data.xsec, precision);

xmlWriteCloseTag (fid, 'GasAbsLookup');

