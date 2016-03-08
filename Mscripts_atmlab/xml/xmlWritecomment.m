% Writes a comment to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStoreWithComment* instead.
%
% FORMAT   result = xmlWritecomment(fid, comment)
%
% IN    fid        File descriptor of XML file
% IN    comment    String

% 2005-08-17   Created by Oliver Lemke.

function result = xmlWritecomment(fid, comment)

xmlWriteTag (fid, 'comment', []);
fprintf (fid, '%s\n', comment);
xmlWriteCloseTag (fid, 'comment');

