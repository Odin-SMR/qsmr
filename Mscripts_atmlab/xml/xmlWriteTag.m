% Write a tag to an XML file.
%
%    Internal function.
%
% FORMAT   xmlWriteTag(fid, name, attrlist)
%
% IN    fid        File descriptor of output file
% IN    name       Tag name
% IN    attrlist   List of attributes

% 2002-12-13   Created by Oliver Lemke.

function xmlWriteTag(fid, name, attrlist)

fprintf(fid, '<%s', name);

j = size(attrlist);

for i = 1:j(1)
  fprintf(fid, ' %s="%s"', attrlist {i,1}, attrlist {i,2});
end

fprintf(fid, '>\n', name);

clear i j name;

