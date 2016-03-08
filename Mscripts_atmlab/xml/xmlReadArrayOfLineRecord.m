% Reads an ARTS cataloguefrom an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadArrayOfLineRecord(fid,attrlist,itype,ftype,binary,fid2)
%
% OUT   result     Array
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-09-25   Created by Oliver Lemke.

function result = xmlReadArrayOfLineRecord(fid,attrlist,itype,ftype,binary,fid2)

ne = str2double (xmlGetAttrValue (attrlist, 'nelem'));

%=== Some old setting varaibles
%
flims  = [0 Inf];
sorted = 0;
ilim   = 0;


%=== Present version number
%
vers = 3;


%=== Check that this is a ARTSCAT file and the version number is correct
%
s = xmlGetAttrValue (attrlist, 'version');

%
if ~strncmp( s, 'ARTSCAT-', 8 )
  error('An ARTS line file must start with "ARTSCAT-"');
end
%
stest = sprintf('ARTSCAT-%d', vers );
%
if ~strncmp( s, stest, length(stest) )
  serr = sprintf('The line file has not the correct version number\n');
  serr = sprintf('%s(it should be %d)',serr,vers);
  error( serr );
end



%=== Read lines 
%
S = next_line( fid );
while isempty(S) & ~feof(fid)
  S = next_line( fid );
end

n     = 0;
%
result     = [];
%
while ~isempty(S)

  f = sscanf( S{2}, '%f' );

  if sorted  &  f >= flims(2)
    break
  end
  
  i0 = sscanf( S{4}, '%f' );
  
  if f >= flims(1)  &  f <= flims(2)  &  i0 >= ilim
    %
    n = n + 1;
    %
    for i = 1:length(S)
  
      switch i
  
       case 1
         result{n}.name = S{i};
        
       case 2
         result{n}.f = f;
     
       case 3
         result{n}.psf = sscanf( S{i}, '%f' );
     
       case 4
         result{n}.i0 = i0;
     
       case 5
         result{n}.t_i0 = sscanf( S{i}, '%f' );
     
       case 6
         result{n}.elow = sscanf( S{i}, '%f' );
     
       case 7
         result{n}.agam = sscanf( S{i}, '%f' );
     
       case 8
         result{n}.sgam = sscanf( S{i}, '%f' );
     
       case 9
         result{n}.nair = sscanf( S{i}, '%f' );
     
       case 10
         result{n}.nself = sscanf( S{i}, '%f' );
     
       case 11
         result{n}.t_gam = sscanf( S{i}, '%f' );
     
       case 12
         result{n}.n_aux = sscanf( S{i}, '%f' );
         n_aux      = result{n}.n_aux;
         %
         % Aux variables are handled below otherwise
     
       case 13 + n_aux
         result{n}.df = sscanf( S{i}, '%f' );
     
       case 14 + n_aux
         result{n}.di0 = sscanf( S{i}, '%f' );
     
       case 15 + n_aux
         result{n}.dagam = sscanf( S{i}, '%f' );
     
       case 16 + n_aux
         result{n}.dsgam = sscanf( S{i}, '%f' );
     
       case 17 + n_aux
         result{n}.dnair = sscanf( S{i}, '%f' );
     
       case 18 + n_aux
         result{n}.dnself = sscanf( S{i}, '%f' );
     
       case 19 + n_aux
         result{n}.dpsf = sscanf( S{i}, '%f' );
     
       case 20 + n_aux
         result{n}.qcode = sscanf( S{i}, '%s' );
     
       case 21 + n_aux
         result{n}.qlower = sscanf( S{i}, '%s' );
     
       case 22 + n_aux
         result{n}.qlower = sscanf( S{i}, '%s' );
     
       case 23 + n_aux
         result{n}.if = sscanf( S{i}, '%s' );
     
       case 24 + n_aux
         result{n}.ii0 = sscanf( S{i}, '%s' );
     
       case 25 + n_aux
         result{n}.ilw = sscanf( S{i}, '%s' );
     
       case 26 + n_aux
         result{n}.ipsf = sscanf( S{i}, '%s' );
     
       case 27 + n_aux
         result{n}.iaux = sscanf( S{i}, '%s' );
      
       otherwise
         %
         if i <= 12+n_aux
           eval(['result{i}.aux',int2str(i-11)]) = sscanf( S{i}, '%f' );
         else
           error(sprintf('To many fields found for line %d.',n));
         end
      end
    end 
  end
  %
  S = next_line( fid );
  %
end

if n ~= ne
  error('Number of lines in catalogue (%d) doesnt match nelem attribute (%d)', n, ne);
end

return



%------------------------------------------------------------------------------

function S = next_line( fid )

  S = [];

  %= Just return if EOF
  if feof(fid)
    return
  end

  %= Read next line
  sin = fgets( fid );

  %= Return if empty line
  if length(sin) < 2
    return
  end

  %= Read until next line that starts with @ and replace line feeds 
  %= with a blank
  %
  if sin(1) ~= '@'
    serr = sprintf('Could not read linefile at:\n%s',sin);
    error( serr );
  end
  % 
  s = [ sin( 3 : (length(sin)-1) ), ' ' ];
  %
  c1 = fscanf(fid,'%c',1);
  %
  while ~isempty(c1) & c1~='@'
    %
    fseek(fid,-1,'cof');   
    %
    sin = fgets( fid );
    s   = [ s, sin( 1 : (length(sin)-1) ), ' ' ];
    %
    c1 = fscanf(fid,'%c',1);
  end

  %= Back one step in the file
  fseek(fid,-1,'cof');   

  %= Field index 
  i = 0;

  while 1

    i = i + 1;

    %= Text field inside " "
    %
    if s(1) == '"'
      %
      iprims = find( s == '"' );
      %
      if length(iprims) < 2
        error('Unmatched " found.');
      end
      %
      S{i} = s(2:(iprims(2)-1));
      %
      l = iprims(2);

    %= Closing tag reached
    %
    elseif s(1) == '<' & s(2) == '/'
      return
    %= Other field
    %
    else

      %= Find field seperations
      iblank = find( s == ' ' );

      %= Pick out text until first blank
      l    = iblank(1) - 1;    
      S{i} = s(1:l);

    end

    %= Remove used text
    s = s( (l+1):length(s) );

    %= Remove blanks at the start of s (if no-blanks, we are ready)
    ichars = find( s ~= ' ' );
    if isempty( ichars )
      return;
    end
    s = s( ichars(1):length(s) );
 
  end
return

