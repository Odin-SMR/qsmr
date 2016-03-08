% Internal function to read attributes of an xml tag.
%
%    Creates a list of attribute name and value pairs.
%
% FORMAT   attrlist = xmlReadAttributes(fid)
%
% OUT   attrlist   List of attributes
% IN    fid        File descriptor of input file
                                                                                                                               
% 2002-09-25   Created by Oliver Lemke.

function attrlist = xmlReadAttributes(fid)

attrlist={};
na = 0;
c = fgets (fid, 1);
while ~feof (fid) && c ~= '>'
  attr = [];
  while ~feof (fid) && c ~= '=' && c ~= '>'
    attr = [attr c];
    c = fgets (fid, 1);
  end
  
  attr = strtrim(attr);

  if c == '>', break, end;

  c = fgets (fid, 1);
  while ~feof (fid) && c == ' '
    c = fgets (fid, 1);
  end

  value = '';
  c = fgets (fid, 1);
  while ~feof (fid) && c ~= '"'
    value = [value c];
    c = fgets (fid, 1);
  end

  na = na + 1;
  attrlist{na,1} = attr;
  attrlist{na,2} = value;
  c = fgets (fid, 1);
end

