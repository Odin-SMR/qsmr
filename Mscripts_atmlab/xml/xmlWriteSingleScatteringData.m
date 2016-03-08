% Writes SingleScatteringData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSingleScatteringData(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       SingleScatteringData
% IN    precision  Precision for floats

% 2005-03-15   Created by Oliver Lemke.

function xmlWriteSingleScatteringData(fid, fidb, data, precision)

xmlWriteTag (fid, 'SingleScatteringData', xmlAddAttribute([], 'version', '2'));

if isnumeric(data.ptype)
    data.ptype = arts_ptype2string(data.ptype);
end

valid_particle_types = { 'general', 'macroscopically_isotropic', ...
                         'horizontally_aligned' };
if ~any( ismember( valid_particle_types, data.ptype ) )
  error('atmlab:xmlWriteScatteringMetaData:IllegalParticleType', ...
        ['Illegal particle_type ' data.particle_type '\n' ...
         'Valid types are: ' sprintf('%s ', valid_particle_types{:})])
end


xmlWriteString (fid, fidb, data.ptype, precision);
xmlWriteString (fid, fidb, data.description, precision);
xmlWriteVector (fid, fidb, data.f_grid, precision);
xmlWriteVector (fid, fidb, data.T_grid, precision);
xmlWriteVector (fid, fidb, data.za_grid, precision);
xmlWriteVector (fid, fidb, data.aa_grid, precision);
xmlWriteTensor7 (fid, fidb, data.pha_mat_data, precision);
xmlWriteTensor5 (fid, fidb, data.ext_mat_data, precision);
xmlWriteTensor5 (fid, fidb, data.abs_vec_data, precision);

xmlWriteCloseTag (fid, 'SingleScatteringData');

