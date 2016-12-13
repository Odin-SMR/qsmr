% returns a structure with data from given scan(s) or
% 
% Usage:
%      y = get_scan_l1b_data(url)
% 
% Out:  
%      y  structure containing l1b data
%         a link to field descriptions to come.. 
% In:    
%     url  string or cell array of strings
%   
% Example Usage:
%      url = 'http://malachite.rss.chalmers.se/rest_api/v4/scan/AC1/2/7002908396'
%      y = get_scan_l1b_data(url)
%
% Created by Bengt Rydberg 2015-12-17
 
function scandata = get_scan_l1b_data(urls)

if ischar(urls)
  y = webread(urls, weboptions('ContentType','json','Timeout',60));
  scandata(1) = y;
  return
end

for i = 1 : length(urls)
  y = webread(urls{i}, weboptions('ContentType','json','Timeout',120));
  scandata(i) = y;
end

