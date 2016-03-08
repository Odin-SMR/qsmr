% Writes XML footer to a file.
%
%    Internal function that should never be called directly.
%
% FORMAT   result = xmlWriteFooter(fid)
%
% IN    fid   File descriptor of XML file
                                                                                                                               
% 2002-12-13   Created by Oliver Lemke.

function result = xmlWriteFooter(fid)

xmlWriteCloseTag(fid, 'arts');

