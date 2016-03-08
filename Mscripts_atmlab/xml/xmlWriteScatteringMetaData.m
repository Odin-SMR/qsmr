% Writes ScatteringMetaData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteScatteringMetaData(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       ScatteringMetaData
% IN    precision  Precision for floats

% 2003-01-09  Created by Oliver Lemke.

function xmlWriteScatteringMetaData(fid, fidb, data, precision)

attrlist = [];
% If data doesn't contain a version number, assume latest version
if isfield(data, 'version')
    nversion = data.version;
    if nversion > 3
        error('atmlab:xmlWriteScatteringMetaData:IllegalVersion', ...
            'Illegal ScatteringMetaData version number')
    end
else
    nversion = 3;
end

attrlist = xmlAddAttribute(attrlist, 'version', sprintf ('%d', nversion));
xmlWriteTag (fid, 'ScatteringMetaData', attrlist);


if nversion < 3
    xmlWriteString (fid, fidb, data.description, precision);
    xmlWriteString (fid, fidb, data.material, precision);
    xmlWriteString (fid, fidb, data.shape, precision);
    xmlWriteNumeric (fid, fidb, data.density, precision);
    xmlWriteNumeric (fid, fidb, data.diameter_max, precision);
    xmlWriteNumeric (fid, fidb, data.volume, precision);
    xmlWriteNumeric (fid, fidb, data.area_projected, precision);
    xmlWriteNumeric (fid, fidb, data.aspect_ratio, precision);

    valid_particle_types = { ...
        'general', 'macroscopically_isotropic', ...
        'horizontally_aligned', 'spherical' };
    if ~any(ismember(valid_particle_types, data.particle_type))
        error('atmlab:xmlWriteScatteringMetaData:IllegalParticleType', ...
            ['Illegal particle_type ' data.particle_type '\n' ...
            'Valid types are: ' sprintf('%s ', valid_particle_types{:})])
    end
    
    xmlWriteVector (fid, fidb, data.scat_f_grid, precision);
    xmlWriteVector (fid, fidb, data.scat_T_grid, precision);
    xmlWriteString (fid, fidb, data.particle_type, precision);
    xmlWriteGriddedField3 (fid, fidb, data.complex_refr_index, precision);
else
    xmlWriteString (fid, fidb, data.description, precision);
    xmlWriteString (fid, fidb, data.source, precision);
    xmlWriteString (fid, fidb, data.refr_index, precision);
    xmlWriteNumeric (fid, fidb, data.mass, precision);
    xmlWriteNumeric (fid, fidb, data.diameter_max, precision);
    xmlWriteNumeric (fid, fidb, data.diameter_volume_equ, precision);
    xmlWriteNumeric (fid, fidb, data.diameter_area_equ_aerodynamical, precision);
end

xmlWriteCloseTag (fid, 'ScatteringMetaData');

