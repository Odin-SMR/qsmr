% returns structures with log and level1b data from a given scan 
% 
% Usage:
%      [L, Y] = get_scan_log_l1b_data(backend,freqmode,scanid)
% 
% Out:  
%      L        structure containing log information of
%               scan and urls to aux-data
%                
%      Y        structure containing Level1BData
%               field description in L1-ATBD 
% In:    
%     backend   'AC1' or 'AC2'
%     freqmode  scalar frequency mode
%     scanid    scalar scan identifier
%   
% Example Usage:
%      backend = 'AC1'
%      freqmode = 2
%      scanid = 7002908396
%      [L, Y] = get_scan_l1b_data(backend,freqmode,scanid)
%     
%
% Created by Bengt Rydberg 2015-12-17
 
function [logdata, y]  = get_scan_log_l1b_data(backend,freqmode,scanid)

url = ['http://malachite.rss.chalmers.se/rest_api/v4/scan/',...
        backend,'/',num2str(freqmode),'/',num2str(scanid)];

y = webread(url, weboptions('ContentType','json','Timeout',60));
% change output format
yfields = fields(y);
for j=1:length(yfields)
  y.(yfields{j}) = y.(yfields{j})';
end

mjd = y.MJD(1);

info = get_logdata4freqmode(freqmode,mjd);
logdata = info(find([info.ScanID]==scanid));

