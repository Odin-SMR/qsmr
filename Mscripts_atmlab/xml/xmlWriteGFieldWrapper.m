% Writes a GField to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGFieldWrapper(fid, fidb, data, precision, dim)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       GriddedField3
% IN    precision  Precision for floats

% 2008-07-02   Created by Oliver Lemke.

function xmlWriteGFieldWrapper(fid, fidb, data, precision, dim)

  % GriddedField
  if isfield( data, 'name' )
    attrlist = xmlAddAttribute ([], 'name', data.name);
  else
    attrlist = [];
  end
  xmlWriteTag (fid, ['GriddedField' sprintf('%d', dim)], attrlist);

  % Grids
  for i = 1:dim
    attrlist = xmlAddAttribute ([], 'name', data.gridnames{i});
    if (length(data.grids{i})~=0 && iscellstr(data.grids{i}(1)))
      xmlWriteArrayOf (fid, fidb, data.grids{i}, 'String', precision, attrlist);
    else
      xmlWriteVector (fid, fidb, data.grids{i}, precision, attrlist);
    end
  end

  % Data
  if isfield( data, 'dataname' )
    attrlist = xmlAddAttribute ([], 'name', data.dataname);
  else
    attrlist = [];
  end
  switch dim
    case 1
      xmlWriteVector (fid, fidb, data.data, precision, attrlist);
    case 2
      xmlWriteMatrix (fid, fidb, data.data, precision, attrlist);
    case 3
      xmlWriteTensor3 (fid, fidb, data.data, precision, attrlist);
    case 4
      xmlWriteTensor4 (fid, fidb, data.data, precision, attrlist);
    case 5
      xmlWriteTensor5 (fid, fidb, data.data, precision, attrlist);
    case 6
      xmlWriteTensor6 (fid, fidb, data.data, precision, attrlist);
    case 7
      xmlWriteTensor7 (fid, fidb, data.data, precision, attrlist);
  end

  xmlWriteCloseTag (fid, ['GriddedField' sprintf('%d', dim)]);

