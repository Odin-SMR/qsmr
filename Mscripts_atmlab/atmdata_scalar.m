% ATMDATA_SCALAR   Ccreates an atmdata structure with a scalar value
%
%   This function can be used for either when the atmdata is a true scalar,
%   or if the field is constant in all dimensions.
%
%   atmdata_scalar( 0 ) generates
%           TYPE: 'atmdata'
%           NAME: []
%         SOURCE: []
%            DIM: 0
%           DATA: 0
%      DATA_NAME: []
%      DATA_UNIT: []
%
% FORMAT   G = atmdata_empty( [ dim ] )
%        
% OUT   G     Created atmlab structure.
% OPT   dim   Dimensionality. Default is 0. Max is 5.

% 2010-01-06   Created by Patrick Eriksson.

function G = atmdata_scalar( value )

if atmlab('STRICT_ASSERT'), 
  rqre_datatype( value, @istensor0 );
end
  
G = atmdata_empty( 0 );

G.DATA = value;
