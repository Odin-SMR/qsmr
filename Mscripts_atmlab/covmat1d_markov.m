% COVMAT1D_MARKOV   Covariance matrix for a Markov process
%
%    The function creates the covariance matrix and its inverse where the
%    correlation can be described as a Markow process. For details, see
%    "Inverse methods for atmospheric sounding" by C.D. Rodgers (Eq. 2.83,
%    Sec. 10.3.2.2 and Exercise 10.2).
%
%    Note that it is possible to have a varying standard deviation, but only
%    a constant correlation length. The function assumes an equidistant grid.
%
% FORMAT   [S,Sinv] = covmat1d_markov( n, sigma, dz, lc [,cco] )
%        
% OUT   S       Covariance matrix, with size n x n. A sparse matrix.
%       Sinv    The inverse of S. A sparse matrix.
% IN    n       Number of points.
%       sigma   Standard devation. Either a scalar value, or a vector of
%               length *n*.
%       dz      Distance between grid points.
%       lc      Correlation length.
% OPT   cco     Correlation cut-off. All values corresponding to a 
%               correlation below this limit are set to 0 in S. This causes
%               S*Sinv to deviate from the identity matrix, but can make S
%               much more sparse.

% 2009-11-06   Created by Patrick Eriksson.


function [S,Sinv] = covmat1d_markov(n,sigma,dz,lc,cco)
%
if nargin < 5
  cco = 0;
end

% Check out *sigma*
%
sigma = vec2col(sigma);
%
lsi = length( sigma );
%
if not( lsi==1 | lsi ==n )
  error( 'The argument *sigma* must have length 1 or *n*.' );
end


% S itself
%
S = (sigma*sigma') .* covmat1d_from_cfun( [0:dz:dz*(n-1)]', 1, 'exp', lc, cco );


if nargout > 1

  % Constants (with 1 std dev set to 1)
  %
  alpha = exp( -dz/lc );
  c1    = -alpha / ( 1 - alpha^2 );
  c2    = 1/(1-alpha^2);

  % Sinv
  %
  row = [ 2:n 1:n 1:n-1 ];
  col = [ 1:n-1 1:n 2:n ];
  w   = [ repmat(c1,1,n-1) c2 repmat(c2*(1+alpha^2),1,n-2) c2 repmat(c1,1,n-1) ];
  %
  Sinv = sparse( row, col, w, n, n ) ./ (sigma*sigma');

end

