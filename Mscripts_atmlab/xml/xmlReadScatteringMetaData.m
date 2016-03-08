% Reads ScatteringMetaData from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the ScatteringMetaData
%    structure.
%
% FORMAT   result = xmlReadScatteringMetaData(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     ScatteringMetaData
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2014-04-03   Created by Oliver Lemke.

function result = xmlReadScatteringMetaData(fid, attrlist, itype, ftype, binary, fid2)

result.version = uint16(str2double (xmlGetAttrValue (attrlist, 'version')));
if result.version > 3
    error('atmlab:xmlReadScatteringMetaData:UnsupportedVersion', ...
        'Unsupported ScatteringMetaData version')
end

if result.version < 3
    result.description    = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.material       = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.shape          = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.density        = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.diameter_max   = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.volume         = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.area_projected = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.aspect_ratio   = xmlReadTag(fid, '', itype, ftype, binary, fid2 );

    if result.version == 2
        result.scat_f_grid        = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
        result.scat_T_grid        = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
        result.particle_type      = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
        result.complex_refr_index = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    end
else
    result.description = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.source      = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.refr_index  = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.mass        = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.diameter_max                    = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.diameter_volume_equ             = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
    result.diameter_area_equ_aerodynamical = xmlReadTag(fid, '', itype, ftype, binary, fid2 );
end
