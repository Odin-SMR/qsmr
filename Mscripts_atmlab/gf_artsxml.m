% GF_ARTSXML   Import of arts XML GriddedField data to gformat
%
%    Imports data having the arts xml GriddedField format. If *type* is given,
%    all fields of G will be filled. Otherwise some will be left empty.
%
%    If file holds ArrayOfGriddedFieldX, one G element is created
%    for each array element.
%
% FORMAT   G = gf_artsxml( file [, name, type ] )
%
% OUT   G       G with imported data appended.
% IN    file    Name of file to read.
% OPT   name    Name of data. Will replace with is read from file if not
%               empty. Default is [].
%       type    Type of data. Default is []. Recognised options are
%                  'vmr_field' : volume mixing ratio field
%                  't_field'   : temperature (atmospheric) field
%                  'z_field'   : altitude (atmospheric) field
%                  'mag_field' : magnetic field component
%                  'wind_field': wind field component

% 2008-09-25   Created by Patrick Eriksson.

function G = gf_artsxml( file, name, type )

if nargin<2
    name=[];
end
if nargin<3
    type=[];
end



%- Load and check data
%
X = xmlLoad( file );
%
G = griddedfield2gf( X, name, type );
%
G.SOURCE = file;
 
return
%-----------------------------------------------------------------------

