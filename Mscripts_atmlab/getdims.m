% GETDIMS   Extract data from specified dimensions
%
%    The function allows a simple way to remove singleton dimensions and change
%    dimensionality of data. This including changing the order of
%    dimensions.
%
%    The dimensions to keep are selected by *dims*. The size of *A* for
%    dimensions not included in *dims* must be 1, but *dims* can include
%    singleton dimensions. It is no demand that *dims* is sorted.
%
%    For example:
%       size(getdims(rand(1,2,1,4,1),[4 3 2])) 
%    gives 
%       4 1 2
%
% FORMAT   B = getdims( A, dims )
%        
% OUT   B      Extracted data.
% IN    A      Original data.
%       dims   Dimensions to extract.

% 2007-10-17   Created by Patrick Eriksson.


function B = getdims(A,dims)



%- Sort dims
%
if issorted(dims)
  sorted = 1;
else
  sorted       = 0;
  [dims,order] = sort( dims );
end

%- Create reshape vector
%
n = ones( 1, max([2 length(dims)]) ); % reshape demands 2 values
%
for id = 1 : length(dims)
  n(id) = size(A,dims(id));
end


%- Reshape
%
B = reshape( A, n );


%- Permute to follow original order of *dims*
%
if ~sorted
  % Determine "back-sorting" order
  [u,order] = sort( order );
  B         = permute( B, order );
end
