% returns a structure with log information
% of scans from the given date and freqmode
% 
% Usage:
%
% y = get_scan_log(url)
%
% Example:
%
% y = get_scan_log('http://webapi:5000/viewscan/2015-01-03/AC1/2')
% 
%  y = 
%
%           AltEnd: [421x1 double]
%         AltStart: [421x1 double]
%         DateTime: {421x1 cell}
%           EndLat: [421x1 double]
%           EndLon: [421x1 double]
%    FirstSpectrum: [421x1 double]
%         FreqMode: [421x1 double]
%             Info: [421x1 struct]
%    LasttSpectrum: [421x1 double]
%              MJD: [421x1 double]
%          NumSpec: [421x1 double]
%           ScanID: [421x1 double]
%         StartLat: [421x1 double]
%         StartLon: [421x1 double]
%            SunZD: [421x1 double]
%
% y.Info(2) =  
%
%    ScanID: 7.003000326000000e+09
%       URL: 'http://webapi:5000/viewodinscan/2015-01-03/AC1/2/7003000326'
%
% use x = get_scan_data(y.Info(2).URL) to get scan data 

function y = get_scan_log(url)

y = webread(url, weboptions('ContentType','json','Timeout',60));
