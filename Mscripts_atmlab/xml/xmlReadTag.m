% Reads a tag from an XML file.
%
%    Internal function. Parses the tag and calls the appropriate reading
%    function.
%
% FORMAT   result = xmlReadTag(fid, filename, binary, ftype, fid2)
%
% OUT   result     Data read from file
% IN    fid        File descriptor of XML file
% IN    filename   Name of XML file
% IN    itype      Only used if called recursively
% IN    ftype      Only used if called recursively
% IN    binary     Only used if called recursively
% IN    fid2       Only used if called recursively

% 2002-11-28   Created by Oliver Lemke.

function [result,attrlist] = xmlReadTag(fid, filename, itype, ftype, binary, fid2, expected_tag)

toplevel = 0;
exit_loop = 0;
result = 'error';

%=== Parsing tags
while ~feof (fid) && ~exit_loop

  c = fgets (fid, 1);
  while ~feof (fid) && (c == 10 || c == 13 || c == 32)
    c = fgets (fid, 1);
  end

  if feof (fid), break, end

  %=== Tag has to start with bracket
  if c == '<'
    c = fgets (fid, 1);

    %=== Do we have an opening tag here?
    if c ~= '/'
      tag = c;

      c = fgets (fid, 1);
      while ~feof (fid) && c ~= ' ' && c ~= '>'
        tag = [tag c];
        c = fgets (fid, 1);
      end
      
      tag = strtrim(tag);

      attrlist = {};
      if feof (fid)
        error ('Unexpected end of file');
      elseif c ~= '>'
        % Tag with attributes
        attrlist = xmlReadAttributes (fid);
      end
      
      switch tag
       case 'arts'
         toplevel = 1;
         format = xmlGetAttrValue (attrlist, 'format');
         if strcmp (format, 'binary')
             binary = 1;
             fid2 = fopen ([filename '.bin'], 'rb');
         end
         fsize = xmlGetAttrValue (attrlist, 'fsize');
         if isempty(fsize)
           ftype = 'double';
         end
         isize = xmlGetAttrValue (attrlist, 'isize');
         if isempty(isize)
           itype = 'long';
         end
       case 'comment'
         buf = '';
         c = fgets (fid, 1);
         while ~feof (fid) && c ~= '>'
           c = fgets (fid, 1);
           buf = [buf c];
         end
         valid = 0;
         if (length(buf) > 9)
           p1 = length(buf)-8;
           p2 = length(buf)-1;
           if strcmp(buf(p1:p2), '/comment')
             valid = 1;
           end
         end

         if valid == 0
           error ('Cannot find closing tag for comment');
         end
        otherwise
           if exist('expected_tag', 'var') && ~isempty(expected_tag) && ~strcmp(expected_tag, tag)
               error ('Wrong tag, expected "%s", but got "%s"', ...
                      expected_tag, tag);
           end
         func = str2func (['xmlRead', tag]);
         result = feval (func, fid, attrlist, itype, ftype, binary, fid2);
      end
    else %=== or is it a closing tag
      c = fgets (fid, 1);
      s = c;
      while ~feof (fid) && c ~= '>'
        c = fgets (fid, 1);
        s = [s c];
      end
      if (~toplevel)
        exit_loop = 1;
      else
        if (strcmp (s, 'arts>') && (fid2))
          fclose (fid2);
        end
      end
    end
  else
    exit_loop = 1;
  end
end

