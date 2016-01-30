function [R,y,J] = q2_oemiter( Q, R, x, iter )

%---------------------------------------------------------------------------
%--- Things done only at first call
%---------------------------------------------------------------------------

if iter == 1

  % Store fixed atmosheric grids and data
  xmlStore( fullfile( R.workfolder, 'p_grid.xml' ), R.ATM.P, ...
                                                         'Vector', 'binary' );
  xmlStore( fullfile( R.workfolder, 't_field.xml' ), R.ATM.T, ...
                                                        'Tensor3', 'binary' );
  xmlStore( fullfile( R.workfolder, 'z_field.xml' ), R.ATM.Z, ...
                                                        'Tensor3', 'binary' );
  % Jacobian for baseline fit
  if Q.BASELINE_PIECEWISE 
  else
    R.Jbl = zeros( size(R.H_TOTAL,1), length(R.ZA_BORESI) );
    nf  = size( R.H_BACKE, 1 );
    for i = 1 : length(R.ZA_BORESI)
      R.Jbl((i-1)*nf+1:i*nf,i) = 1;
    end
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
%--- Update vmr_field
%---------------------------------------------------------------------------

xmlStore( fullfile( R.workfolder, 'vmr_field.xml' ), vmr, ...
                                                        'Tensor4', 'binary' );

  
  
  
%---------------------------------------------------------------------------
%--- Run ARTS 
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
y = R.H_TOTAL * y;
%
if do_j  
  
  % Load Jacobian
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
  
  % Add weightimng functions for baseline fit
  J = [ J, R.Jbl ] ; 
end


%- Add baseline
%
if iter > 1
  y = y + R.bl;
end
