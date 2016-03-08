% OEM   Data inversion by "optimal estimation method"
%
%   The name OEM is here kept as it is so well established in the atmospheric
%   community. A better name would be "the maximum a posteriori solution". See
%   "Inverse methods for atmospheric sounding: Theory and practice" by C.D.
%   Rodgers for background and theory.
%
%   The OEM calculations are controlled by the structure O. The fields of O,
%   and associated descriptions, are listed by
%      qinfo(@oem)
%
%   The Marquardt-Levenberg method is implemented following Eq. 5.36 of
%   Rodgers' book. The gamma factor, here denoted as ga, is not allowed to
%   exceed O.ga_max. When a succesful iteration has been performed, ga is
%   decreased following O.ga_factor_ok. For cases when a lower cost is not
%   obtained, ga is increased by O.ga_factor_not_ok. Values of ga below 1 will
%   be treated as zero. If not a lower cost is obtained for ga=0, then ga=1 is
%   tested. O.ga_start is used as start value for ga.
%
%   The results are gathered in a structure X, with fields:
%      x         : Retrieved state.
%      converged : Convergence flag. 1 if convergency criterion has been 
%                  reached. Otherwise 0 for non-linear inversions when the
%                  maximum number of iterations is reached, or -1 for 
%                  Marquardt-Levenberg when the maximum value for gamma is
%                  passed. Set to -1 also for linear retrievals.
%      cost      : Total cost, normalised by length of y. A succesful retrieval
%                  shall then have a cost in the order of 1.
%      cost_y    : Cost corresponding to the measurement vector.
%      cost_x    : Cost corresponding to the state vector.
%      dx        : Change in the state vector x between each iteration.
%                  A normalisation to the length of x is applied.
%      ga        : The Marquardt-Levenberg parameter for each iteration.
%      e         : Total retrieval error (square root of diagonal elements 
%                  of S).
%      eo        : Observation error (square root of diagonal elements of So).
%      es        : Smoothing error (square root of diagonal elements of Ss).
%      ex        : A priori uncertainty (square root of diag elements of Sx).
%      yf        : Fitted spectrum.
%      A         : Averaging kernel matrix.
%      G         : Gain matrix (also denoted as Dy).
%      J         : Jacobian (weighting function matrix).
%      S         : Covariance matrix for total error. That is, the sum
%                  of So and Ss.
%      So        : Covariance matrix for observation error.
%      Ss        : Covariance matrix for smoothing error.
%      Xiter     : The x-vector after each iteration.
%   The fields *x* and *converged* are always included (if an actual inversion 
%   is performed). Other fields are included if corresponding O field is set.
%   Note that the case x=x0, where x0 is the start value of x, is treated as
%   iteration 1, and the first value in variables covering all iterations 
%   corresponds to the sitatuation when no inversion/iteration has been
%   performed. 
%
%   The communication with the forward model is handled by the function
%   handle comfun. If comfun is set to @arts_oem, the following calls will 
%   be made:
%      [R,yf,J]  = arts_oem( Q, R, x, iter );
%      [R,yf]    = arts_oem( Q, R, x, iter );
%   That is, this function expects the comfun function to provide spectrum 
%   and jacobian (only spectrum in the second case) for present state (the x 
%   vector). The oem function does not use any information in Q and R, and
%   the comfun function is free to use these variables freely for bookkeeping
%   etc. This function handles y, x, Sx and Se as totally generic variables
%   and unit conversion and similar tasks are left to the comfun and
%   post-processing. 
%
%   Use the first format to check default values for O. The second format
%   is intended for extracting retrieval characteristics (corresponding to
%   a linear inversion). The third format performs a complete inversion.
%
% FORMAT   O = oem
%            or
%          [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa)
%            or
%          [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa,y)
%        
% OUT   O        O structure with default value for all recognised fields.
%       X        Retrieved state and additional information.
%       R        Retreival variable structure from last calculation.
% IN    O        OEM setting structure.
%       Q        Forward model setting structure.
%       R        Retreival variable structure.
%       comfun   Handle to function for communication with forward model.
%       Sx       Covariance matrix for a priori uncertainty.
%       Se       Covariance matrix for observation uncertainties.
%       Sxinv    The inverse of Sx. If set to [], the inverse is calculated 
%                internally.
%       Seinv    The inverse of Se. If set to [], the inverse is calculated 
%                internally.
%       xa       A priori profile.
%       y        Measurement vector.

function [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa,y)

  
%=============================================================================
%=== Definition of O
%=============================================================================
  
if ~nargin

%-----------------------------------------------------------------------------
O.A = false;
I.A = [ ...
'Flag to include averaging kernel matrix in X. Default is 0.'
];
%-----------------------------------------------------------------------------
O.cost = false;
I.cost = [ ...
'Flag to include cost values in X and to calculate cost even if solution ',...
'method does not require cost values. This affects also the output to ',...
'*outfids*.'
];
%-----------------------------------------------------------------------------
O.dx = false;
I.dx = [ ...
'Flag to include the sequence of convergence values (defined as for *stop_dx*).'
];
%-----------------------------------------------------------------------------
O.e = false;
I.e = [ ...
'Flag to include in X the estimate of total retrieval error  (square root ',...
'of diagonal elements of S). That is, the standard deviation for the sum ',...
'of observation and smoothing errors.'
];
%-----------------------------------------------------------------------------
O.eo = false;
I.eo = [ ...
'Flag to include in X the estimate of observation error (square root of ',...
'diagonal elements of So).'
];
%-----------------------------------------------------------------------------
O.es = false;
I.es = [ ...
'Flag to include in X the estimate of smootning error (square root of ',...
'diagonal elements of Ss).'
];
%-----------------------------------------------------------------------------
O.ex = false;
I.ex = [ ...
'Flag to include in X the a priori uncertainty (square root of ',...
'diagonal elements of Sx).'
];
%-----------------------------------------------------------------------------
O.G = false;
I.G = [ ...
'Flag to include gain matrix in X (alse denoted as Dy).'
];
%-----------------------------------------------------------------------------
O.ga = false;
I.ga = [ ...
'Flag to include Marquardt-Levenberg parameter in X. Default is 0.'    
];
%-----------------------------------------------------------------------------
O.ga_factor_not_ok = 3;
I.ga_factor_not_ok = [ ...
'The factor with which the Marquardt-Levenberg factor is increased when not ',...
'a lower cost value is obtained. This starts a new sub-iteration. This value ',...
'must be > 1.'    
];
%-----------------------------------------------------------------------------
O.ga_factor_ok = 2;
I.ga_factor_ok = [ ...
'The factor with which the Marquardt-Levenberg factor is decreased after a ',...
'lower cost values has been reached. This value must be > 1.'    
];
%-----------------------------------------------------------------------------
O.ga_max = 100;
I.ga_max = [ ...
'Maximum value for gamma factor for the Marquardt-Levenberg method. The ',...
'stops if this value is reached and cost value is still not decreased. ',...'
'This value must be > 0.'
];
%-----------------------------------------------------------------------------
O.ga_start = 4;
I.ga_start = [ ...
'Start value for gamma factor for the Marquardt-Levenberg method. Type:',...
'#   help oem',...
'#for a definition of the gamma factor. This value must be >= 0.'
];
%-----------------------------------------------------------------------------
O.itermethod = 'ML';
I.itermethod = [ ...
'Iteration method. Choices are ''GN'' for Gauss-Newton and ''ML'' or',...
'''LM'' for Marquardt-Levenberg.'
];
%-----------------------------------------------------------------------------
O.J = false;
I.J = [ ...
'Flag to include weighting function matrix in X.'
];
%-----------------------------------------------------------------------------
O.jexact = false;
I.jexact = [ ...
'Flag to select recalculation of J after last iteration. If not set to 1, ',...
'J will correspond to x before last iteration. Also used for the linear case.'
];
%-----------------------------------------------------------------------------
O.jfast = false;
I.jfast = [ ...
'Flag to always calculate the Jacobian in parallel to the spectrum. This ',...
'field is only used for the Marquardt-Levenberg case. This option can save ',...
'time if the calculation of the Jacobian is very fast and the convergence ',...
'is smooth (few cases where ga has to be increased). The advanatge of this ',...
'option is that the next iteration can be started without a call of the ',...
'forward model.'
];
%-----------------------------------------------------------------------------
O.linear = false;
I.linear = [ ...
'Flag to trigger a linear inversion. Fields like itermethod are ignored if ',...
'this option is selected. Default is non-linear (0).'
];
%-----------------------------------------------------------------------------
O.maxiter = 99;
I.maxiter = [ ...
'Maximum number of iterations.'
];
%-----------------------------------------------------------------------------
O.msg = [];
I.msg = [ ...
'Message to put at the start of output messages. Can include e.g. number ',...
'of retrieval case.'
];
%-----------------------------------------------------------------------------
O.outfids = 1;
I.outfids = [ ...
'File identifiers for output messages. Inlcude 1 for the screen. Set to [] ',...
'for no output att all.'
];
%-----------------------------------------------------------------------------
O.S = false;
I.S = [ ...
'Flag to include covariance matrix for total error in X. That is, the sum ',...
'of So and Ss.'
];
%-----------------------------------------------------------------------------
O.So = false;
I.So = [ ...
'Flag to include covariance matrix for observation error in X.'
];
%-----------------------------------------------------------------------------
O.Ss = false;
I.Ss = [ ...
'Flag to include covariance matrix for smoothing error in X.'
];
%-----------------------------------------------------------------------------
O.stop_dx = 1e-3;
I.stop_dx = [ ...
'Stop criterion. The iteration is halted when the change in x ',...
'is < stop_dx (see Eq. 5.29 in Rodgers'' book). A normalisation to the ',...
'length of x is applied.'
];
%-----------------------------------------------------------------------------
O.yf = false;
I.yf = [ ...
'Flag to include "fitted spectrum" in X. That is, the simulated ',...
'measurement matching retrieved state.'
];
%----------------------------------------------------------------------------- 
O.Xiter = false;
I.Xiter = [ ...
'Flag to include all iteration states in X.'
];
%-----------------------------------------------------------------------------
 
X = O;
R = I; 
return  
end
  




%==============================================================================
%=== Start of calculation part
%==============================================================================


%=== Check and adoption of input ==============================================

  % STRICT_ASSERT part has been removed
  
  %- Some post-processing of input                                          
  %
  if ~O.linear
    if strcmp( upper(O.itermethod), 'GN' )
      O.itermethod = 'GN';  
    elseif strcmp( upper(O.itermethod), 'ML' )  |  ...
           strcmp( upper(O.itermethod), 'LM' )
        O.itermethod = 'ML';
        O.cost       = true;  % Note default value here, cost must 
        %                       anyhow be calculated
    end
  end

  % Apply "xnorm" on Sx and Sxinv
  xnorm = full( sqrt( diag( Sx ) ) );  % Avoid that xnorm inherits sparse
  Sx    = Sx ./ (xnorm*xnorm');        % from Sx!
  %
  if nargin < 7  |  isempty(Sxinv)
    Sxinv = full_or_sparse( Sx \ speye(size(Sx)) );
  else
    Sxinv = Sxinv .* (xnorm*xnorm');
  end
  
  % Make sure Seinv is at hand
  if nargin < 8  |  isempty(Seinv)
    Seinv = full_or_sparse( Se \ speye(size(Se)) );
  end

    
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



  
%=== Stuff common to all calculation options ==================================

  %- Print initial screen message
  %
  if ~isempty( O.msg )  |  out(2)
    out( 1, 1, O.outfids );
  end
  if ~isempty( O.msg )
    out( 1, O.msg, O.outfids );
    out( 3, 0, O.outfids );
  end

  %- Make sure that X is initialised as a structure
  %
  X.converged = -1;   % Expected output for the linear case

  %- xa is used as initial linearisation point
  %
  x    = xa;
  iter = 1;
  %
  if O.Xiter
    X.Xiter(:,iter) = x;
  end
  %
  if O.dx
    X.dx(iter) = NaN;
  end

  %- Is J valid for last x?
  %
  j_updated = 0;

  %- dx and ga not always used, but always printed:
  %
  dx = NaN;
  ga = 0;
  

  
  
  
%=== Only characterisation ====================================================

  if nargin < 10
    %
    out( 1, 'Performing linear characterisation ...' );
    J = NaN;

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  
  
  
  
%=== Make inversion ===========================================================
%  
  else
    
    % The different cases are handled separately to avoid a lot of flags, if
    % statements and control variables. Helps also to save memory and to make
    % the calculations in most efficient way. The drawback is that more or less
    % the same code is found at several places.
    
    
    %=== Linear inversion =====================================================
    %
    if O.linear

      %- Messages
      out( 3, 'Linear inversion', O.outfids );
      if O.cost
        out( 3, 0, O.outfids );
        nlinprint( O.outfids );
      end

      %- Calculate Jacobian
      [R,yf,J] = calc_y_and_j( comfun, Q, R, O, xnorm, x, iter );

      %- Calculate cost
      if O.cost
        X = calc_cost_for_X( y, yf, Seinv, xa, x, Sxinv, O, xnorm, X, iter );
        nlinprint( O.outfids, iter, ga, X.cost(iter), X.cost_x(iter), ...
                                                        X.cost_y(iter), dx );
      end
      
      %- Some matrix products (also used in common part below)
      JtSeinv = J' * Seinv;
      SJSJ    = Sxinv + JtSeinv * J;

      %- Calculate x
      xstep   = SJSJ \ ( JtSeinv * ( y - yf ) ); 
      %
      x = x + xnorm .* xstep;
      %
      iter = iter + 1;      
      if O.Xiter
        X.Xiter(:,iter) = x;
      end
      
      %- Flag that yf and J are not valid for x
      yf        = NaN;
      j_updated = 0;

      % cost for last state is handled below in a common way
        
        
        

        
    %=== GN iteration ========================================================
    %
    elseif strcmp( O.itermethod, 'GN' )
      
      %- Messages
      out( 3, 'Non-linear inversion: Gauss-Newton', O.outfids );
      if O.cost
        out( 3, 0, O.outfids );
        nlinprint( O.outfids );
      end

      converged = 0;
      %
      while ~converged  &  iter <= O.maxiter

        %- Calculate Jacobian
        [R,yf,J] = calc_y_and_j( comfun, Q, R, O, xnorm, x, iter );

        %- Calculate cost
        if O.cost
          X = calc_cost_for_X( y, yf, Seinv, xa, x, Sxinv, O, xnorm, X, iter );
          nlinprint( O.outfids, iter, ga, X.cost(iter), X.cost_x(iter), ...
                                                          X.cost_y(iter), dx );
        end
        
        %- Some matrix products (also used in common part below)
        JtSeinv = J' * Seinv;
        SJSJ    = Sxinv + JtSeinv * J;

        %- Weighted difference between y and yf
        if iter == 1
          wdy = JtSeinv * ( y - yf );
        else
          wdy = JtSeinv * ( y - yf ) - Sxinv * ( ( x - xa ) ./ xnorm );
        end
      
        %- Calculate new x
        %
        xold  = x;  
        xstep = SJSJ \ wdy;
        %
        x = x + xnorm .* xstep;
        %
        iter = iter + 1;   
        %
        if O.Xiter
          X.Xiter(:,iter) = x;
        end

        %- Test for convergence
        [converged,dx,X] = test_convergence( xold, x, SJSJ, O, xnorm, X, iter );
        
      end % while ~converged
      
      %- Flag that yf and J are not valid for x
      yf        = NaN;
      j_updated = 0;

      % cost for last state is handled below in a common way
      
      
      

        
    %=== ML iteration ========================================================
    %
    elseif strcmp( O.itermethod, 'ML' )
      
      %- Messages
      out( 3, 'Non-linear inversion: Marquardt-Levenberg', O.outfids );
      if O.cost
        out( 3, 0, O.outfids );
        nlinprint( O.outfids );
      end
      
      %- Iteration
      ga_treshold = 1;
      ga          = O.ga_start;
      converged   = 0;
      first_iter  = 1;
      %
      while ~converged  &  iter <= O.maxiter

        %- Calculate Jacobian
        if ~j_updated
          [R,yf,J] = calc_y_and_j( comfun, Q, R, O, xnorm, x, iter );
        end

        %- If first iteration, cost is unknown.
        %- For later iterations, the gamma factor shall be decreased
        if first_iter
          [cost,cost_y,cost_x] = ...
                              calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm );
          %
          nlinprint( O.outfids, iter, NaN, cost, cost_x, cost_y, dx );
          if O.cost
            X.cost(iter)   = cost;
            X.cost_y(iter) = cost_y;
            X.cost_x(iter) = cost_x;
            X.ga(iter) = NaN;
          end
          first_iter = 0;
        else
          if ga >= O.ga_factor_ok * ga_treshold;
            ga = ga / O.ga_factor_ok;
          else
            ga = 0;
          end   
        end 
        
        %- Weighted difference between y and yf (not dependent on ga)
        %
        JtSeinv  = J' * Seinv;   % Neither dependent on ga
        JtSeinvJ = JtSeinv * J;   
        %
        if iter == 1
          wdy = JtSeinv * ( y - yf );
        else
          wdy = JtSeinv * ( y - yf ) - Sxinv * ( ( x - xa ) ./ xnorm );
        end
        
        %- Find new x
        % 
        xfound   = 0;
        cost_old = cost;
        %
        while ~xfound 

          %- New x state
          if ga > 0
            SJSJ = (1+ga)*Sxinv + JtSeinvJ;      
          else  
            SJSJ = Sxinv + JtSeinvJ;
          end   
          %
          xstep = SJSJ \ wdy; 
          %
          xnew = x + xnorm .* xstep;
          
          %- New fitted spectrum
          if O.jfast
            [R,yf,J]  = calc_y_and_j( comfun, Q, R, O, xnorm, xnew, iter+1 );
            j_updated = 1; 
          else
            [R,yf] = feval( comfun, Q, R, xnew, iter+1 );
          end

          %- Check if lower cost has been reached
          [cost,cost_y,cost_x] = ...
                          calc_cost( y, yf, Seinv, xa, xnew, Sxinv, O, xnorm );
          %
          if cost < cost_old
            xfound = 1;
            iter   = iter + 1;
            if O.cost
              X.cost(iter)   = cost;
              X.cost_y(iter) = cost_y;
              X.cost_x(iter) = cost_x;
              X.ga(iter) = ga;       
            end
            if O.Xiter
              X.Xiter(:,iter) = xnew;
            end
          else
            nlinprint( O.outfids, -99, ga, cost, cost_x, cost_y, NaN );
            if ga < ga_treshold
              ga = ga_treshold;
            else
              if ga < O.ga_max
                ga = ga * O.ga_factor_not_ok;
                if ga > O.ga_max
                  ga = O.ga_max;
                end
              else
                X.converged = -1;
                yf          = NaN;
                break;    % New x could not be found !!!
              end
            end   
          end
          
        end %while ~xfound 

        %- Test for convergence
        if xfound
          %
          if ga > 0 % If yes, then SJSJ includes gamma, which we don't 
                    % want here
            SJSJ = Sxinv + JtSeinvJ;
          end   
          %
          [converged,dx,X] = ...
                          test_convergence( x, xnew, SJSJ, O, xnorm, X, iter );
          nlinprint( O.outfids, iter, ga, cost, cost_x, cost_y, dx );
          x = xnew;
        else
          break;
        end
      end % while ~converged
      
      %- J can not be used for error characterisation if ga > 0
      %
      if ga > 0
        j_updated = 0;
        J         = NaN;
      end
      
    else
      error( 'Unknown retrieval option.' );    
    end
  end % of retrieval option part


  
  


%=== Update/calculate basic inversion variables ===============================

  %- Update J?
  %
  if O.J | O.G | O.A | O.S | O.So | O.Ss | O.e | O.eo | O.es    
    %
    if isnan(J)  |  ( O.jexact  &  ~j_updated ) 
      [R,yf,J] = calc_y_and_j( comfun, Q, R, O, xnorm, x, iter );
      %
      JtSeinv  = J' * Seinv;
      SJSJ     = Sxinv + JtSeinv * J;
    end
  end
  
  %- Calculate G ?
  %
  if O.G | O.A | O.S | O.So | O.Ss | O.e | O.eo | O.es
    G = ( SJSJ \ speye(size(Sxinv)) ) * JtSeinv;
    % back-normalisation with xnorm must be done after calculation of A
  end

  %- Calculate A ?
  %
  if O.A | O.S | O.Ss | O.e | O.es
    A = G * J;
  end

  
  
  
  
%=== Fill X ===================================================================

  X.x = x;
    
  if O.cost  &  length(X.cost) < iter
    if isnan(yf)
      [R,yf] = feval( comfun, Q, R, x, iter );
    end
    X = calc_cost_for_X( y, yf, Seinv, xa, x, Sxinv, O, xnorm, X, iter );
    nlinprint( O.outfids, iter, ga, X.cost(iter), X.cost_x(iter), ...
                                                  X.cost_y(iter), dx );
                                              
    X.ga(iter) = ga;
  end

  if O.yf
    if isnan(yf)
      [R,yf] = feval( comfun, Q, R, x, iter );
    end
    %
    X.yf = yf;
  end

  if O.J
    X.J = J ./ repmat( xnorm', size(J,1) , 1 );
  end

  if O.G
    X.G = G .* repmat( xnorm, 1, size(G,2) );
  end

  if O.A 
    X.A = A .* (xnorm*(1./xnorm'));  %scaling is ni/nj, where ni is xnorm
  end                                %for retrieved value, and nj for x-state

  if O.S  |  O.So  |  O.e  |  O.eo
    So = G * Se * G';
    %
    So = So .* (xnorm*xnorm');
    %
    if O.So
      X.So = So;
    end
    %
    if O.eo
      X.eo = full( sqrt( diag( So ) ) );
    end
  end  

  if O.S  |  O.Ss  |  O.e  |  O.es
    AI = A - eye(size(A,1));
    Ss = AI * Sx * AI';
    clear AI;
    %
    Ss = Ss .* (xnorm*xnorm');
    %
    if O.S
      X.S = Ss + So;
    end
    %
    if O.Ss
      X.Ss = Ss;
    end
    %
    if O.e
      X.e = full( sqrt( diag( Ss ) + diag( So ) ) );
    end
    %
    if O.es
      X.es = full( sqrt( diag( Ss ) ) );
    end
  end  

  if O.ex
    X.ex = full( sqrt( diag( Sx ) ) .* xnorm );
  end
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



%=== End of main part =========================================================
  
  %= End screen meassages 
  %
  if ~isempty( O.msg )  |  out(2)
    out( 1, -1, O.outfids );
  end
  
  return

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^





%= Internal sub-functions =====================================================

%=== nlinprint ================================================================
  %
  function nlinprint(outfids,iter,ga,cost,xcost,ycost,dx)
    %
    if nargin == 1
     out( 2,'             Gamma       Total   Profile   Spectrum    Converg.',...
                                                                     outfids );
     out( 2,'Iteration   factor        cost      cost       cost     measure',...
                                                                     outfids );
    else
     if iter == 1, ga = NaN; end
     out( 2, sprintf('%9.0f%9.1f%12.3f%10.2f%11.2f%12.2f', iter, ga, ...
                                           cost, xcost, ycost, dx ), outfids );
    end
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  
%=== calc_cost ================================================================
  %
  function [cost,cost_y,cost_x] = calc_cost(y,yf,Seinv,xa,x,Sxinv,O,xnorm)
    dd     = x - xa;
    dd     = dd ./ xnorm;
    ny     = length( y );
    cost_x = (dd' * Sxinv * dd) / ny;  
    dd     = y - yf;
    cost_y = (dd' * Seinv * dd) / ny; 
    cost   = cost_x + cost_y;
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    
%=== calc_cost_for_X ==========================================================
  %
  function X = calc_cost_for_X(y,yf,Seinv,xa,x,Sxinv,O,xnorm,X,iter)
    %
    [cost,cost_y,cost_x] = calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm );
    %
    X.cost(iter)   = cost;
    X.cost_y(iter) = cost_y;
    X.cost_x(iter) = cost_x;
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    

%=== calc_y_and_j =============================================================
  %
  function [R,yf,J] = calc_y_and_j(comfun,Q,R,O,xnorm,x,iter)
    %
    [R,yf,J]  = feval( comfun, Q, R, x, iter );
    %
    J = J .* repmat( xnorm', size(J,1), 1 );
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


%=== test_convergence =========================================================
  %
  function [converged,dx,X] = test_convergence(xold,xnew,SJSJ,O,xnorm,X,iter)
    %
    dd = xnew - xold;
    %
    dd = dd ./ xnorm;
    %
    dx = ( dd' * SJSJ * dd ) / length(xnew);
    %
    if dx <= O.stop_dx
      converged   = 1;
    else
      converged   = 0;
    end
    X.converged   = converged;
    if O.dx
      X.dx(iter)  = dx;
    end
    %
  return  
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^