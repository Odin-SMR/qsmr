% Q2_ARTS_SENSOR   Calculates complete sensor reponse matrix
%
%   This function assumes that R contains the partial response matrices
%   produced by *q2_arts_sensor_parts*. These partial responses are expanded
%   and combined to create the complete response matrix, returned as R.H_TOTAL.
%
% FORMAT R = q2_arts_sensor(R)
%
% OUT   R      Modified R structure.
% IN    R      R structure.

% 2015-05-29   Created by Patrick Eriksson.

function R = q2_arts_sensor(R)

  
% Expand antenna part
%
[i,j,s] = find( R.H_ANTEN );
%
nfin = size( R.H_BACKE{1}, 2 );
ns   = length( s );
%
[ii,jj,ss] = deal( zeros( ns*nfin, 1 ) );
p          = 0;
%
for v = 1 : ns
  for f = 1 : nfin
    p     = p + 1;
    ii(p) = (i(v)-1)*nfin + f;
    jj(p) = (j(v)-1)*nfin + f;
    ss(p) = s(v);
  end
end
%
H1 = sparse( ii, jj, ss, size(R.H_ANTEN,1)*nfin, size(R.H_ANTEN,2)*nfin );



% Backend, if LO assumed to be constant 
%
if length(R.H_BACKE) == 1

  % Expand mixer + backend
  %
  [i,j,s] = find( R.H_BACKE{1} );
  %
  nbore = size( R.H_ANTEN,    1 );
  nfout = size( R.H_BACKE{1}, 1 );
  ns    = length( s );
  %
  [ii,jj,ss] = deal( zeros( ns*nbore, 1 ) );
  p          = 0;
  %
  for b = 1 : nbore
    i0 = (b-1) * nfout;
    j0 = (b-1) * nfin;
    for v = 1 : ns
      p     = p + 1;
      ii(p) = i(v) + i0;
      jj(p) = j(v) + j0;
      ss(p) = s(v);
    end
  end
  %
  H2 = sparse( ii, jj, ss, nbore*nfout, size(H1,1) );


% Mixer+backend, with varying f_backend 
else
  nbore = size( R.H_ANTEN, 1 );
  nfout = size( R.H_BACKE{1}, 1 );
  p     = 0;
  %
  for b = 1 : nbore
    %

    [i,j,s] = find( R.H_BACKE{b} );
    ns    = length( s );
    %
    if b == 1
      % Here we allocate with 50% margin, as number of elements can change
      [ii,jj,ss] = deal( zeros( round(1.5*ns*nbore), 1 ) );
    end
    %
    i0 = (b-1) * nfout;
    j0 = (b-1) * nfin;
    for v = 1 : ns
      p     = p + 1;
      ii(p) = i(v) + i0;
      jj(p) = j(v) + j0;
      ss(p) = s(v);
    end
  end
  %
  i  = 1:p;
  H2 = sparse( ii(i), jj(i), ss(i), nbore*nfout, size(H1,1) );
end



% Complete sensor matrix
%
R.H_TOTAL = H2 * H1;