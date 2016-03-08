% Reads a String from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadString(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     String
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-01-09   Created by Oliver Lemke.

function result = xmlReadString(fid, attrlist, itype, ftype, binary, fid2)

c = fgets (fid, 1);
while ~feof (fid) && (c == 10 || c == 32)
  c = fgets (fid, 1);
end

if c ~= '"'
  error ('Invalid string: Not starting with "');
end

% Read the string charwise from input file
% Because matlab removes trailing spaces from strings
% it becomes a bit more complicated.
result = '';
c = fgets (fid, 1);
while ~feof (fid) && c ~= '"'
  result = [result c];
  c = fgets (fid, 1);
end

result = strtrim(result);

if c ~= '"'
  error ('Invalid string: Not ending with "');
end

clear whitespace_count c

