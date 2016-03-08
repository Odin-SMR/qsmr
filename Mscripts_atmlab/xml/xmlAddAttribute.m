% Internal function to add a name/value pair to an attribute list.
%
%    Used by the writing routines to create the attribute list for a tag.
%
% FORMAT   attrlist = xmlAddAttribute(attrlist, name, value)
%
% OUT   attrlist   List of attributes
% IN    attrlist   List of attributes
% IN    name       Attribute name
% IN    value      Attribute value
                                                                                                                               
% 2002-12-13   Created by Oliver Lemke.

function attrlist = xmlAddAttribute(attrlist, name, value)

j = size(attrlist);
na = j(1);

na = na + 1;
attrlist{na,1} = name;
attrlist{na,2} = value;

