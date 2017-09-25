% returns a structure with aux (ptz or apriori)
% data for given scan(s)
%
% Usage:
%      y = get_scan_aux_data(url)
%
% Out:
%      y  structure containing l1b aux data
%         a link to field descriptions to come..
% In:
%     url  string or cell array of strings
%
% Example Usage:
%
%      url = 'http://malachite.rss.chalmers.se/rest_api/v4/ptz/2015-01-03/AC1/2/7002908396'
%      url = 'http://malachite.rss.chalmers.se/rest_api/v4/apriori/O3/2015-01-03/AC1/2/7002908396'
%      y = get_scan_aux_data(url)
%
% Created by Bengt Rydberg 2015-12-17

function scandata = get_scan_aux_data(urls)

% From version v5, the actual data come out as y.Data. The data are repacked
% to remove this level, effectively going back to v4.

if ischar(urls)
  y = webread_retry(urls, weboptions('ContentType','json','Timeout', 300), 5);
  if isfield(y,'Count') & isfield(y,'Data')
    scandata(1) = y.Data;
  else
    scandata(1) = y;
  end
  return
end

for i = 1 : length(urls)
  y = webread_retry( urls{i}, ...
                     weboptions('ContentType','json','Timeout', 300), 5);
  scandata(i) = y;
end
