function [R,y,J] = q2_oemiter( Q, R, x, iter )

%---------------------------------------------------------------------------
%--- Things done only at first call
%---------------------------------------------------------------------------

if iter == 1

  % Store fixed atmosheric grids and data
  xmlStore( fullfile( R.workfolder, 'p_grid.xml' ), R.ATM.P, ...
                                                         'Vector', 'binary' );
  xmlStore( fullfile( R.workfolder, 'z_field.xml' ), R.ATM.Z, ...
                                                        'Tensor3', 'binary' );
  if Q.T.RETRIEVE
    R.t_apriori = interpp( R.ATM.P, R.ATM.T, Q.T.GRID );
  else
    xmlStore( fullfile( R.workfolder, 't_field.xml' ), R.ATM.T, ...
                                                        'Tensor3', 'binary' );
  end
  
  % Jacobian for baseline fit
  %
  if Q.BASELINE.RETRIEVE    
    R.Jbl = zeros( size(R.H_TOTAL,1), size(R.bline_ilims,2)*length(R.ZA_BORESI) );
    %
    nf = size( R.H_BACKE, 1 );  % Number of channels
    c  = 0;
    %
    for t = 1 : length(R.ZA_BORESI)
      for i = 1 : size(R.bline_ilims,2)
        c  = c + 1;
        i0 = (t-1) * nf;
        R.Jbl(i0+R.bline_ilims(1,i):i0+R.bline_ilims(2,i),c) = 1;
      end
    end
  else
    R.Jbl = [];
  end
end



%---------------------------------------------------------------------------
%--- Perform mapping from x to ARTS or baseline variables 
%---------------------------------------------------------------------------

vmr  = R.ATM.VMR;
R.bl = 0;


%- Loop retrieval quantities
%
for i = 1 : length( R.jq )

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag

   case 'Absorption species'   %----------------------------------------------
    %
    ig      = R.i_asj(i);    % Gas species index
    xmapped = interpp( Q.ABS_SPECIES(ig).GRID, x(ind), R.ATM.P );
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      vmr(ig,:) = vmr(ig,:) .* xmapped';
    elseif strcmp( R.jq{i}.mode, 'logrel' )
      vmr(ig,:) = vmr(ig,:) .* exp(xmapped');
    else 
      assert( false );
    end
    clear xmapped ig
   
   case 'Atmospheric temperatures'   %---------------------------------------
    %
    t_field = interpp( Q.T.GRID, R.t_apriori + x(ind), R.ATM.P );
   
   case 'Sensor pointing'   %-------------------------------------------------
    %
    if iter > 1
      xmlStore( fullfile( R.workfolder, 'sensor_los.xml' ), ...
                R.ZA_PENCIL + x(ind), 'Matrix', 'binary' );
    end

   case 'Frequency'   %--------------------------------------------------------
    %
    if iter > 1
      L1B                  = R.L1B;
      L1B.Frequency.LOFreq = L1B.Frequency.LOFreq   + x(ind);
      %
      R = q2_arts_sensor_parts( L1B, Q, R, 'mixer' );
      R = q2_arts_sensor_parts( L1B, Q, R, 'backend' );
      R = q2_arts_sensor( R );
    end
    
   case 'Polynomial baseline fit'   %-----------------------------------------
    %
    if iter > 1
      R.bl = R.bl + R.Jbl * x(ind);
    end

   otherwise   %--------------------------------------------------------------
      error('Unknown retrieval quantitity.'); 
  end 
end 



%---------------------------------------------------------------------------
%--- Update atmospheric fields
%---------------------------------------------------------------------------

xmlStore( fullfile( R.workfolder, 'vmr_field.xml' ), vmr, ...
                                                        'Tensor4', 'binary' );
if Q.T.RETRIEVE
  xmlStore( fullfile( R.workfolder, 't_field.xml' ), t_field, ...
                                                        'Tensor3', 'binary' );
end

  
  
  
%---------------------------------------------------------------------------
%--- Run ARTS, load results, expand J and apply sensor matrix
%---------------------------------------------------------------------------

if nargout == 3
  do_j  = 1;
  cfile = R.cfile_yj;
else
  do_j  = 0;
  cfile = R.cfile_y;
end
%
arts( cfile );
%
y = xmlLoad( fullfile( R.workfolder, 'y.xml' ) );
%
if do_j  
  
  % Load Jacobian and apply sensor response matrix
  J = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );
  J = R.H_TOTAL * J;

  % Jacobian calculated for x, but for "rel" it should be with respect to xa:
  % (as arts takes x as xa, no scaling needed for "logrel", and no scaling 
  %  needed for first calculation)
  if iter > 1 & ~isempty( R.i_rel )
    for i = vec2row(R.i_rel)
      J(:,i) = J(:,i) / x(i);
    end
  end  
  
  % Derive pointing off-set weighting functions
  %
  if Q.POINTING.RETRIEVE
    nf = size( R.H_MIXER, 2 );  % Length of f_grid
    dza = 0.001;
    ymat = reshape( y, [nf length(R.ZA_PENCIL) ] );
    ytmp = interp1( R.ZA_PENCIL, ymat', R.ZA_PENCIL+dza, 'pchip', 'extrap' )'; 
    Jpoi = R.H_TOTAL * ( ytmp(:) - y ) / dza;
  else
    Jpoi = [];
  end

  % Derive frequency off-set weighting functions
  %
  if Q.FREQUENCY.RETRIEVE    
    df   = 5e3;
    ytmp = interp1( R.F_GRID, ymat, R.F_GRID+df, 'pchip', 'extrap' ); 
    Jfre = R.H_TOTAL * ( ytmp(:) - y ) / df;
  else
    Jfre = [];  
  end
  
  % Expand Jacobian with locally derived parts
  J = [ J, Jpoi, Jfre, R.Jbl ] ; 

end


% Apply sensor response matrix on y
y = R.H_TOTAL * y;


%- Add baseline
%
if iter > 1
  y = y + R.bl;
end
