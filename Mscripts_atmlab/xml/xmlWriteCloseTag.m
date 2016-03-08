% Write a closing tag to an XML file.
%
%    Internal function.
%
% FORMAT   xmlWriteCloseTag(fid, name)
%
% IN    fid        File descriptor of output file
% IN    name       Tag name

% 2002-12-13   Created by Oliver Lemke.

function xmlWriteCloseTag(fid, name)

fprintf(fid, '</%s>\n', name);

