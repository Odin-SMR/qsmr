% returns a structure with information
% of which frequency modes that were
% observed the given date
%
% Usage:
%
% y = get_date_info(url)
%
% Example:
%
% date = '2015-01-03'
% webapi_url = get_webapi_url();
% url = [ webapi_url,'/viewscan/',date];
% y = get_date_info(url)
%
% y =
%     Date: {'2015-01-03'}
%     Info: [2x1 struct]
%
% y.Info(1) =
%  Backend: 'AC1'
% FreqMode: 2
%  NumScan: 419
%      URL: 'http://webapi:5000/viewscan/2015-01-03/AC1/2'
%
% Use x = get_scan_log(y.Info(1).URL) to get log information
% of all scans
%
function y = get_date_info(url)

%url = 'http://webapi:5000/viewscan/2009-10-04';

y = webread(url, weboptions('ContentType','json','Timeout',60));




