% Internal function to get the value of an attribute.
%
%    Takes an attribute name and returns its value if found in the
%    attribute list.
%
% FORMAT   value = xmlGetAttrValue(attrlist, name)
%
% OUT   value      Attribute value
% IN    attrlist   List of attributes
% IN    name       Retrieve value of attribute with name
 
% 2002-09-25   Created by Oliver Lemke.

function value = xmlGetAttrValue(attrlist, name)

j = size(attrlist);

value = [];

for i = 1:j(1)
  if strcmp (attrlist {i,1}, name)
    value = attrlist {i,2};
    break;
  end
end

clear i j name;

