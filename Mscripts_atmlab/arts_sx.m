% ARTS_SX   Creation of Sx matrix based on Qarts/ARTS data
%
%    This is a standardised function to set up Sx. The function simply includes
%    the covariance matrices defined in the SX sub-fields along the diagonal of
%    the complete Sx matrix. That is, the function handles only covariances
%    inside each retrieval quantity. The result will be a (sparse) matrix with
%    non-zero elements in blocks around the diagonal.
%
% FORMAT   [Sx,Sxinv] = arts_sx( Q, R )
%        
% OUT   Sx      Covariance matrix (sparse).
%       Sxinv   Inverse of Sx
% IN    Q       Qarts structure. See *qarts*.
%       R       Retrieval data structure. See *arts_oem*.

% 2006-09-07   Created by Patrick Eriksson.


function [Sx,Sxinv] = arts_sx( Q, R )



%--- Initialization of variables ----------------------------------------------

%- xa
%
nq = length( R.jq );
nx = R.ji{nq}{2};
%
Sx = sparse( nx, nx );
%
i_asj = find( [ Q.ABS_SPECIES.RETRIEVE ] );

%- Sxinv
if nargout > 1
  do_sxinv = true;
  Sxinv    = sparse( nx, nx );
else
  do_sxinv = false;
end


%--- Loop retrieval quantities and fill xa and R fields -----------------------
%------------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag

   case 'Absorption species'   %-----------------------------------------------
    %
    ig = i_asj(i);    % Gas species index
    %
    Sx(ind,ind) = Q.ABS_SPECIES(ig).SX;
    %
    % Here we need to catch that SXINV can be empty. This happens if SXINV
    % is set for one species, but not others.
    if do_sxinv
      if isfield( Q.ABS_SPECIES(ig), 'SXINV' )  &  ...
            ~isempty(Q.ABS_SPECIES(ig).SXINV)
        Sxinv(ind,ind) = Q.ABS_SPECIES(ig).SXINV;
      else
        Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
      end
    end

    
   case 'Atmospheric temperatures'   %-----------------------------------------
    %
    Sx(ind,ind) = Q.T.SX;
    %
    if do_sxinv
      if isfield( Q.T, 'SXINV' )
        Sxinv(ind,ind) = Q.T.SXINV;
      else
        Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
      end
    end

    
   case 'Wind'   %-------------------------------------------------------------
    %
    if strcmp( R.jq{i}.subtag, 'u' )             
        %
      Sx(ind,ind) = Q.WIND_U.SX;
      %
      if do_sxinv
        if isfield( Q.WIND_U, 'SXINV' )
          Sxinv(ind,ind) = Q.WIND_U.SXINV;
        else
          Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
        end
      end
      %
    elseif strcmp( R.jq{i}.subtag, 'v' )             
        %
      Sx(ind,ind) = Q.WIND_V.SX;
      %
      if do_sxinv
        if isfield( Q.WIND_V, 'SXINV' )
          Sxinv(ind,ind) = Q.WIND_V.SXINV;
        else
          Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
        end
      end
      %
    elseif strcmp( R.jq{i}.subtag, 'w' ) 
        %
      Sx(ind,ind) = Q.WIND_W.SX;
      %
      if do_sxinv
        if isfield( Q.WIND_W, 'SXINV' )
          Sxinv(ind,ind) = Q.WIND_W.SXINV;
        else
          Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
        end
      end
      %
    else                                                                    %&%
      error( 'Unknown wind subtag.' );                                      %&%
    end

    
    
   case 'Sensor pointing'   %--------------------------------------------------
    %
    %
    Sx(ind,ind) = Q.POINTING.SX;
    %
    if do_sxinv
      if isfield( Q.POINTING, 'SXINV' )
        Sxinv(ind,ind) = Q.POINTING.SXINV;
      else
        Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
      end
    end

    
   case 'Frequency'   %--------------------------------------------------------
    %
    if strcmp( R.jq{i}.subtag, 'Shift' )
      %
      Sx(ind,ind) = Q.FSHIFTFIT.SX;
      %
      if do_sxinv
        if isfield( Q.FSHIFTFIT, 'SXINV' )
          Sxinv(ind,ind) = Q.FSHIFTFIT.SXINV;
        else
          Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
        end
      end
      %
    end

    
   case 'Polynomial baseline fit'   %------------------------------------------
    %
    c      = sscanf( R.jq{i}.subtag(end+[-1:0]), '%d' );
    sxname = sprintf( 'SX%d', c );
    %
    Sx(ind,ind) = Q.POLYFIT.(sxname);
    %
    if do_sxinv
      sxname = sprintf( 'SXINV%d', c );
      if isfield( Q.POLYFIT, sxname )
        Sxinv(ind,ind) = Q.POLYFIT.(sxname);
      else
        Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
      end
    end

    
   case 'Sinusoidal baseline fit'   %------------------------------------------
    %
    c      = sscanf( R.jq{i}.subtag(end+[-1:0]), '%d' ) + 1;
    sxname = sprintf( 'SX%d', c );
    %
    Sx(ind(1:2:end),ind(1:2:end)) = Q.SINEFIT.(sxname);
    Sx(ind(2:2:end),ind(2:2:end)) = Q.SINEFIT.(sxname);
    %
    if do_sxinv
      sxname = sprintf( 'SXINV%d', c );
      if isfield( Q.SINEFIT, sxname )
        Sxinv(ind(1:2:end),ind(1:2:end)) = Q.SINEFIT.(sxname);
        Sxinv(ind(2:2:end),ind(2:2:end)) = Q.SINEFIT.(sxname);
      else
        Sxinv(ind,ind) = Sx(ind,ind) \ speye(length(ind));
      end
    end

    
  otherwise   %----------------------------------------------------------------
    error( sprintf('Unknown retrieval quantity (%s).',R.jq{i}.maintag) ); 
  end

end



