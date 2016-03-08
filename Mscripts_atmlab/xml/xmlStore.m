% Writes data to an XML file.
%
%    This is the generic writing routine for XML files. You have to give
%    the filename, the data and the type of data as a string.
%
%    E.g. writing the vector v to file 'vect.xml':
%
%    xmlStore ('vect.xml', v, 'Vector');
%
%    Make sure that the data you're passing has the correct type.
%
% FORMAT   xmlStore(filename, data, type, precision)
%
% IN    filename   Name of output file
% IN    data       Data
% IN    type       Data type
% IN    precision  Precision for output of floating point numbers, could be
%                  either 'FLOAT' or 'DOUBLE' or 'BINARY' (Default:'FLOAT')
%                  Binary files always have double precision and 4-byte
%                  integer with little-endian byte-order

% 2002-12-16  Created by Oliver Lemke.


function xmlStore(filename, data, type, precision)

if nargin < 4
  xmlStoreImpl(filename, '', data, type)
else
  xmlStoreImpl(filename, '', data, type, precision)
end

