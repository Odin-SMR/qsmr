% Writes  data to an XML file.
%
%    This is the generic writing routine for XML files. You have to give
%    the filename, the data and the type of data as a string.
%
%    E.g. writing the vector v to file 'vect.xml':
%
%    xmlStoreImpl ('vect.xml', 'Some comment', v, 'Vector');
%
%    Make sure that the data you're passing has the correct type.
%
% FORMAT   xmlStoreImpl(filename, comment, data, type, precision)
%
% IN    filename   Name of output file
% IN    comment    Comment to store along with the data
% IN    data       Data
% IN    type       Data type

% 2002-12-16  Created by Oliver Lemke.


function xmlStoreImpl(filename, comment, data, type, precision)

%=== Basic ckeck of input
%
rqre_nargin( 2, nargin );
%
if nargin < 5
  precision = 'FLOAT';
end

precision = upper(precision);

if (~strcmp(precision, 'FLOAT')) ...
        && (~strcmp(precision, 'DOUBLE')) ...
        && (~strcmp(precision, 'BINARY'))
    error ('Invalid value for precision. Must be either FLOAT, DOUBLE or BINARY');
end

fidb = -1;
if (strcmp(precision, 'BINARY'))
    fidb = xmlOpenBinaryOutputFile (filename);
end

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid, fidb);

if ~isempty(comment)
  xmlWritecomment (fid, comment);
end

if length (type) > 14 && strcmp(type (1:14), 'ArrayOfArrayOf')
  xmlWriteArrayOfArrayOf (fid, fidb, data, type(15:length(type)), precision);
elseif length (type) > 7 && strcmp(type (1:7), 'ArrayOf')
  xmlWriteArrayOf (fid, fidb, data, type (8:length(type)), precision);
else
  func = str2func (['xmlWrite' type]);
  feval (func, fid, fidb, data, precision);
end

xmlWriteFooter (fid);
fclose (fid);

if (fidb ~= -1), fclose(fidb); end

