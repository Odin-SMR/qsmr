% returns a structure with data from a given scan
%
% Usage:
%      y = get_scan_data(url)
%
% Example Usage:
%      url = 'http://webapi:5000/viewscan/2015-01-03/AC1/2/7003000326'
%      y = get_scan_data(url)
% 
%

function y = get_scan_data(url)


y = webread(url, weboptions('ContentType','json','Timeout',60));

% change output format 
yfields = fields(y);
for i=1:length(yfields)
  y.(yfields{i}) = y.(yfields{i})';
end

% calculate frequency 



rm_edge_chs = true;
if y.Backend(1)==1;
    bad_modules = [1,2];
elseif y.Backend(1)==2;
    bad_modules = [3];
end

sortmeth = 'mean';
numspec = round(length(y.Type)/2);
f = qsmr_frequency(y,numspec);
f_modules = mean(f);
remove_modules = f_modules(bad_modules);
f = f(:);
s = y.Spectrum(:,numspec);
[y.Frequency,y.Spectrum] = smrl1b_ac_freqsort(f,y.Spectrum,remove_modules,rm_edge_chs,sortmeth);


