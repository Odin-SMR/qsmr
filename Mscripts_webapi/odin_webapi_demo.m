% A demonstration how to search and extract odin data
%
% In this demo it is shown how to:
% 
% * find out which freqmodes that were measured fo a range of dates
% * get log data for a given freqmode and range of dates
% * get scan l1b data 
% * get scan ptz data
% * get scan a priori data

test_database = 0;
webapi_url = get_webapi_url(); %connect to test database

% get which freqmodes that were measured within a date range
 
mjd1 = datenum('2015-01-03') - datenum('1858-11-17');
mjd2 = datenum('2015-01-04') - datenum('1858-11-17');

if test_database == 1
  freqmodes = get_measuredfreqmodes4daterange(mjd1,mjd2,webapi_url);
else
  freqmodes = get_measuredfreqmodes4daterange(mjd1,mjd2);
end

if isempty(freqmodes)
  display('No data found for the desired dates')
  return
end

%------------------------------------------------------------

% get scan logdata for all scans from a given freqmode
% within a given date range 

freqmode = freqmodes(2);

if test_database == 1
  info = get_logdata4freqmode(freqmode,mjd1,mjd2,webapi_url);
else
  info = get_logdata4freqmode(freqmode,mjd1,mjd2);
end

%--------------------------------------------------------------

% filter logdata in order to decide which scans to load
%   : we here select all scans where the endlat or startlat
%     are within +-10 degree 

lat = 10;
index1 = find( abs([info.EndLat])<lat | abs([info.StartLat])<lat);
index2 = find( [info.MJD]<mjd2);
index = intersect(index1,index2);

info = info(index);
%-------------------------------------------------------------

% read scan data

% {info.URL} cell array of urls
scandata = get_scan_l1b_data({info.URL}); 

if 0
  % get ptz and o3 apriori data
  ptzdata = get_scan_aux_data({info.URL_ptz});
  o3data =  get_scan_aux_data({info.URL_apriori_O3}); 
  % or if you want to get several a priori data
  apriori = {'H2O','O3','O2','N2'};
  % this loop will return H2Odata,O3data,O2data, and N2 data
  for i=1:length(apriori)
    urls = eval(['{info.URL_apriori_',apriori{i},'}']);  
    eval([apriori{i},'data = get_scan_aux_data(urls)']);
  end
end


if 0
  % also possible to for url to be a string
  url = info(1).URL;
  scandata = get_scan_l1b_data(url);
  url = info(1).URL_ptz;
  ptzdata  = get_scan_aux_data(url);
  url = info(1).URL_apriori_O3;
  o3data   = get_scan_aux_data(url);
end

%--------------------------------------------------------------

% plot data
figure
set(gcf,'PaperPositionMode','auto')
hFig = figure(1);
set(hFig, 'Position', [0 0 1200 600])
set(gca,'FontSize',8)

for i = 1:min(length(scandata),9)

  [s1,s2] = size(scandata(i).Spectrum);
  lofreq = ones(s1,1) * scandata(i).Frequency.LOFreq';
  IFreqmat = scandata(i).Frequency.IFreqGrid * ones(1,s2);
  freqmat = lofreq + IFreqmat;
  okind = find(~bitget(scandata(i).Quality,find(bitget(hex2dec('0020'),1:8))));
  subplot(3,3,i)
  plot( freqmat(:,okind(3:end))/1e9, scandata(i).Spectrum(:,okind(3:end) ) )
  grid on
  str = sprintf('ScanID: %s Source: %s',num2str(scandata(i).ScanID(1)),scandata(i).Source{1});
  title(str,'fontsize',8)
  xlabel('Freq. [GHz]') 
  ylabel('Tb [K]')
  ylim([-10,250])

end







