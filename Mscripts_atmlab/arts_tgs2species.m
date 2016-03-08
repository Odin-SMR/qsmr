% ARTS_TGS2SPECIES  Extracts species name from tag definitions
%
%    Returns species or isotopologe name. For example,
%    'H20-161-501e9-505e9' is converted to 'H2O' or 'H2O-161', depending on
%    status of *iso*. 
% 
%    Note that the internal arts format is not handled here (as in 
%    *arts_tgs_cnvrt*). 
%
%    Example:
%       arts_tgs2species( Q.ABS_SPECIES(i).TAG{1} )
%
% FORMAT   species = arts_tgs2species( a, iso )
%        
% OUT   species   Species name. 
% IN    a         Tag. A string. 
% OPT   iso       Include isotopomer numbers. Default is false.

% 2007-05-14   Created by Patrick Eriksson.


function species = arts_tgs2species( a, iso )
if nargin < 2
  iso = false;
end

ind = find( a == '-' );

% Expand to cover all possible cases
ind = [ ind repmat(length(a)+1,1,2) ];
  
if ~iso 
  species = a(1:ind(1)-1);
else
  species = a(1:ind(2)-1);
end   

