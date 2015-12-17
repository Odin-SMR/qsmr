function l1b_demo

freqmode  = 1;
scanindex = 9;
mjd       = date2mjd( 2014, 11, 25 );
ztan_low  = 18e3;
ztan_high = 65e3;


% Get scan log data 
%  
logdata = get_logdata4freqmode( freqmode, mjd, mjd+1 );


% Read selected scan
%
l1b = get_scan_l1b_data( logdata(scanindex).URL ); 


% Crop in tangent altitude
%
ind = find( l1b.Altitude >= ztan_low  &  ...
            l1b.Altitude <= ztan_high &  ...
            l1b.Type     == 8 );  
%
l1b = l1b_crop( l1b, ind );



% Determine frequency vectors
%
F = l1b_frequency( l1b );



