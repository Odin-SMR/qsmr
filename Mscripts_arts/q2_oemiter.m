function [R,y,J] = q2_oemiter( Q, R, x, iter )

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
    
    otherwise   %--------------------------------------------------------------
      error('Unknown retrieval quantitity.'); 
  end 
end 



%---------------------------------------------------------------------------
%--- Store to files
%---------------------------------------------------------------------------

if iter == 1
  xmlStore( fullfile( R.workfolder, 't_field.xml' ), R.ATM.T, ...
                                                        'Tensor3', 'binary' );
  xmlStore( fullfile( R.workfolder, 'z_field.xml' ), R.ATM.Z, ...
                                                        'Tensor3', 'binary' );
end
%
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
end


%- Add baseline
%
if iter > 1
  y = y + R.bl;
end
