% GRIDINTERP  Change of rectangular grid in 1D to 5D
%
%    Atmlabs function for interpolation that can be seen as a change the
%    underlaying grid(s). That is, conversion of data between two
%    multi-dimensional rectangular grids. This is basically an interface to
%    to the standard interp1 and interpn functions.
%
%    For "point interpolation", see accompanying function *pointinterp*.
%
%    The grids of the data to be interpolated (*A*) are packed into the vector
%    array *agrids*. Grids for interpolated data are packed in the same in
%    *newgrids*. The length of these grids determine the size of *B*.
%    That is, the number of input arguments is not changed by the data
%    dimension.
%
%    All grids must be sorted in ascending order (demand of interpn).
%    The Atmlab convention of that 1D objects (including grids) are column
%    vectors is here strictly followed.
%
%    The function allows a special treatment of extrapolation by the optional
%    argument *extrap*. If set to false, standard matlab functionality is
%    obtained. If set to true, then data are treated to be constant outside end
%    points. That is, the data values at end points are assumed to be valid to
%    -Inf andf Inf, respectively. This can also be seen as a "nearest"
%    interpolation for positions outside the covered range. This feature is
%    also applied on singleton dimensions (resulting in a constant value for
%    that dimension between -Inf to Inf).
%
%    A note: For "unsmooth" data, this function should be avoided when going
%    from a finer to a coarser grid. For such cases, consider the function
%    *resample_geodata*.
%
% FORMAT   B = gridinterp(agrids,A,newgrids[,iopt])
%
% OUT   B          Interpolated data.
% IN    agrids     Grids of A, as an array of vectors.
%       A          Data to be interpolated.
%       newgrids   Grids for interpolation, as an array of vectors.
% OPT   iopt       Interpolation option. See *interpn*. Default is 'linear'.
%       extrap     Special treatment of extrapolation. See above.
%                  Default is false.

% 2006-08-22   Created by Patrick Eriksson.


function B = gridinterp(agrids,A,newgrids,varargin)
%
[iopt,extrap] = optargs( varargin, { 'linear', false } );

    outdim = length(newgrids);
    %- Check a or determine a's effective dimensions
    %
    if extrap    % Ignore singleton dimensions
        dims = find( size( A ) > 1 );
        A    = getdims( A, dims );
    else
        dims = 1:outdim;
    end
    
    dim = length( dims );
    
    if dim == 0
        B = A;
    elseif dim == 1
        if extrap
            xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
        else
            xi = newgrids{dims(1)};
        end
        B = interp1( agrids{dims(1)}, A, xi, iopt );
        
    elseif dim == 2
        if extrap
            xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
            yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
        else
            xi = newgrids{dims(1)};
            yi = newgrids{dims(2)};
        end
        [xi,yi] = ndgrid( xi, yi );
        B = interpn( agrids{dims(1)}, agrids{dims(2)}, A, xi, yi, iopt );
        
    elseif dim == 3
        
        if extrap
            xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
            yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
            zi = handle_expand( agrids{dims(3)}, newgrids{dims(3)} );
        else
            xi = newgrids{dims(1)};
            yi = newgrids{dims(2)};
            zi = newgrids{dims(3)};
        end
        [xi,yi,zi] = ndgrid( xi, yi, zi );
        B = interpn( agrids{dims(1)}, agrids{dims(2)}, agrids{dims(3)}, ...
            A, xi, yi, zi, iopt );
        
    elseif dim == 4
        if extrap
            xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
            yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
            zi = handle_expand( agrids{dims(3)}, newgrids{dims(3)} );
            ui = handle_expand( agrids{dims(4)}, newgrids{dims(4)} );
        else
            xi = newgrids{dims(1)};
            yi = newgrids{dims(2)};
            zi = newgrids{dims(3)};
            ui = newgrids{dims(4)};
        end
        [xi,yi,zi,ui] = ndgrid( xi, yi, zi, ui );
        B = interpn( agrids{dims(1)}, agrids{dims(2)}, ...
            agrids{dims(3)}, agrids{dims(4)}, A, xi, yi, zi, ui, iopt );
        
    elseif dim == 5
        if extrap
            xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
            yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
            zi = handle_expand( agrids{dims(3)}, newgrids{dims(3)} );
            ui = handle_expand( agrids{dims(4)}, newgrids{dims(4)} );
            vi = handle_expand( agrids{dims(5)}, newgrids{dims(5)} );
        else
            xi = newgrids{dims(1)};
            yi = newgrids{dims(2)};
            zi = newgrids{dims(3)};
            ui = newgrids{dims(4)};
            vi = newgrids{dims(5)};
        end
        [xi,yi,zi,ui,vi] = ndgrid( xi, yi, zi, ui, vi );
        B = interpn( agrids{dims(1)}, agrids{dims(2)}, agrids{dims(3)}, ...
            agrids{dims(4)}, agrids{dims(5)}, A, xi, yi, zi, ui, vi, iopt );
        
        %- Post-processing for *extrap*
        %
        if extrap  &&  dim < outdim
            % Make extrapolation for A's singleton dimensions
            map = ones( 1, max([2 outdim]) ); % Repmat demands at least two values
            lg  = ones( 1, max([2 outdim]) );
            for d = 1 : outdim
                lg(d) = max([ 1 length( newgrids{d} ) ] );  % The 1 to handle empty grids
                if ~any( dims == d )  &&  lg(d) > 1          % for singleton dimensions
                    map(d) = length( newgrids{d} );
                end
            end
            if any( map > 1 )
                B = repmat( B, map );
            end
            
            % Full dimension is not obtained above for some cases of singleton
            % dimensions. Fixed by a reshape
            bsize = size(B);
            if length(bsize) < length(lg)  ||  any( bsize ~= lg )
                B = reshape( B, lg );
            end
        end
        
    end


%---
function xi = handle_expand(x,xi)
%

% use find instead of indexing because the code relies on i1 sometimes being = []

v1 = min( x );
i1 =  find( xi<v1 ) ;
%
v2 = max( x );
i2 = find( xi>v2 );
%
if ~isempty(v1)
    xi(i1) = v1;
end
%
if ~isempty(v2)
    xi(i2) = v2;
end
%
return