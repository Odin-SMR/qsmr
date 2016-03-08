% ARTS_TGS_CNVRT   Convert species tag information 
%
%    The function convert species tag data between Atmlab and ARTS
%    formats. The ARTS format is a string, with each group inside 
%    " " and group items seperated with commas. Tags are stored in Atmlab
%    as string arrays, such as a = {ClO}. For example,
%       b = arts_tgs_cnvrt({'H2O-*-490e9-510e9','H2O-PWR98'})
%    gives
%       b = '"H2O-*-490e9-510e9,H2O-PWR98"';
%    
%    The function handles also definition of multiple species. The data must
%    then be packed into the field 'TAG' of a structure array:  
%       a.TAG{1} = 'ClO';
%       a.TAG{1} = 'O3';
%       a,TAG{1} = 'H2O';
%       a.TAG{2} = 'H2O-MPM89';
%    which results in the string
%       '"ClO","O3","H2O,H2O-MPM89"'
%
%    The conversion from ARTS to atmlab format produces always the later 
%    format (a.TAG).
%
%    The function performs conversion in both directions, where the input
%    format is determined by the type of the input argument *a*.
%
% FORMAT   b = arts_tgs_cnvrt( a )
%        
% OUT   b   Species tag data information in output format.
% IN    a   Species tag data information in input format.

% 2004-09-08   Created by Patrick Eriksson.


function b = arts_tgs_cnvrt( a )


if iscellstr( a )
  %
  b = '"';
  for i = 1 : length(a)-1
    b = sprintf( '%s%s,', b, a{i} );
  end
  b = sprintf( '%s%s"', b, a{end} );

elseif isstruct( a )
  %                                                                    %&%
  if ~isfield( a, 'TAG' )                                              %&%
    error( 'If *a* is a structure, it must have the field ''TAG''.' ); %&%
  end                                                                  %&%
  %
  b = '';
  for i = 1 : length(a)-1
    b = sprintf( '%s%s,', b, arts_tgs_cnvrt( a(i).TAG ) );
  end
  b = sprintf( '%s%s', b, arts_tgs_cnvrt( a(end).TAG ) );

else
  %
  ind = find( a == '"' );
  if isodd( length(ind) )                                              %&%
    error( ...                                                         %&%
    'This is not a valid ARTS species tag string (odd number of ").'); %&%
  end
  %
  for i = 1 : 2 : length(ind)
    s = a( (ind(i)+1) : (ind(i+1)-1) );
    ind2 = [0 find( s == ',' ) length(s)+1];
    for j = 1 : (length(ind2)-1)
      b(round(0.5+i/2)).TAG{j} = s( (ind2(j)+1) : (ind2(j+1)-1) );
    end
  end
end