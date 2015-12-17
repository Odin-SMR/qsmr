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
%      url = 'http://malachite.rss.chalmers.se/rest_api/v3/scan/AC1/2/7002908396'
%      y = get_scan_l1b_data(url)
%      see also odin_webapi_demo.m for usage
%
% Created by Bengt Rydberg 2015-12-17
 
function scandata = get_scan_l1b_data(urls)

if ischar(urls)
  y = webread(urls, weboptions('ContentType','json','Timeout',60));
  % change output format
  yfields = fields(y);
  for j=1:length(yfields)
    y.(yfields{j}) = y.(yfields{j})';
  end
  scandata(1) = y;
  return
end

for i = 1 : length(urls)
  y = webread(urls{i}, weboptions('ContentType','json','Timeout',60));
  % change output format
  yfields = fields(y);
  for j=1:length(yfields)
    y.(yfields{j}) = y.(yfields{j})';
  end
  scandata(i) = y;
end

