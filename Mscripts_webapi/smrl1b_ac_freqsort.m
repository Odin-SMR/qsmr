% smrl1b_ac_freqsort   Sorts AC spectra
%
%   Auto-correlator spectra are sorted, on the same time as data coming from
%   bad modules, and with interference from internal IF signals, can be
%   removed. AC spectra have over-lapping parts. That is, some frequencies are
%   repeated.
%
%   Modules to be removed are specified by selecting a frequency inside the
%   module. This frequency can not be inside overlapping frequency
%   parts. This argument can be a vector. Several modules are then removed.
%
%   If *rm_edge_channels* is set, then first and last channel of each module
%   is removed. This in order to remove possible contamination of internal
%   IF signals. 
%
%   Spectra can be sorted in several ways (*sortmeth*):
%
%     'mean' : Data at over-lapping frequencies are averaged.
%
%     'from_start' : First value for duplictaed frequencies is kept. Second
%     value is ignored.
%
%     'from_end' : Second value for duplicated frequencies is kept. First
%     value is ignored.
%
%   The function can sort several spectra in parallel. Each frequency and
%   spectrum vector is then a column in *f* and *y*, respectively. The
%   sorting is based then solely on data in first column of *f*.
%
% FORMAT   [f,y] = smrl1b_ac_freqsort(f,y,bad_modules,rm_edge_chs,sortmeth)
%        
% OUT   f           Sorted frequency column vector(s). 
%       y           Sorted spectrum column vector(s).
% IN    f           Sorted frequency vector.
%       y           Sorted spectrum vector.
% OPT   bad_modules See above. Default is [].
%       rm_edge_chs Removal of egede channels. Default is false.
%       sortmeth    See above. Default is 'mean'.

% 2006-11-08   Created by Patrick Eriksson.


function [f,y] = smrl1b_ac_freqsort(f,y,bad_modules,rm_edge_chs,sortmeth)
  
  
%- Default input values
%
if nargin < 3
  bad_modules = [];
end
if nargin < 4  |  isempty(rm_edge_chs)
  rm_edge_chs = false;
end
if nargin < 5  |  isempty(sortmeth)
  sortmeth = 'mean';
end

%- Check input
%
if ~((size(f,1) == 896) | (size(f,1) == 448)) ...
  | ~((size(y,1) == 896) | (size(y,1) == 448))  
  error('Input data must be columns with length 448 or 896.');  
end


if size(f,1) == 896 

 %- Remove bad modules
 %
 if ~isempty( bad_modules )  |  rm_edge_chs

  ind = ones(896,1);
  
  if ~isempty( bad_modules )
    %- find frequency limit for each module
    fs = reshape( f(:,1), 112, 8 );
    fs = [ min(fs); max(fs) ];
    
    for i = 1:length(bad_modules)
    
      ii = find( bad_modules(i) >= fs(1,:)  &  bad_modules(i) <= fs(2,:) );
      
      if length(ii) == 0 
        error( sprintf( ...
            'Bad module frequency %.3f GHz is outside covered range.', ...
            bad_modules(i)/1e9 ) );
      elseif length(ii) > 1
        error( sprintf( ...
            'Frequency %.3f GHz does not give unique module identification.',...
            bad_modules(i)/1e9 ) );      
      end
      
      ind((ii-1)*112 + (1:112)) = 0;
      
    end
  end
  
  if rm_edge_chs
    ind([1:112:896 112:112:896]) = 0;  
  end
  
  ind = find( ind );
  
  f = f(ind,:);
  y = y(ind,:);
  
 end

end

%- Sort
%
if strcmp( sortmeth, 'from_start' )
  [f,y] = sort_from_start( f, y );
elseif strcmp( sortmeth, 'from_end' )
  [f,y] = sort_from_end( f, y );
elseif strcmp( sortmeth, 'mean' )
  [f1,y1]  = sort_from_start( f, y );
  [f2,y2]  = sort_from_end( f, y );
  f        = f1;
  y        = ( y1 + y2 ) / 2;
else
  error(sprintf('Unrecognised selection for sorting method (%s).',sortmeth));
end




function [f,y] = sort_from_start(f,y)
  n = size( f, 1 );
  [fu,ind] = unique( f(n:-1:1,1) );
  ind      = n + 1 - ind;
  f        = f(ind,:);
  y        = y(ind,:);
return  


function [f,y] = sort_from_end(f,y)
  [fu,ind] = unique( f(:,1) );
  f        = f(ind,:);
  y        = y(ind,:);
return
