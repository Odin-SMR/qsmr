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
 
mjd1 = datenum('2014-01-01') - datenum('1858-11-17');
mjd2 = datenum('2014-01-02') - datenum('1858-11-17');
mjdvec = mjd1:mjd2;

if test_database == 1
  freqmode4dates = get_measuredfreqmodes4daterange(mjdvec,webapi_url);
else
  freqmodes4dates = get_measuredfreqmodes4daterange(mjdvec);
end

if isempty(freqmodes4dates)
  display('No data found for the desired dates')
  return
end

%------------------------------------------------------------

% get scan logdata for all scans from a given freqmode
% within a given date range 

freqmode = freqmodes4dates{1}.freqmodes(1);

first check if the freqmode was deployed for all dates
mjdvec_tmp = [];
for i = 1:length(freqmodes4dates)
  if any( freqmodes4dates{i}.freqmodes == freqmode )
     mjdvec_tmp = [mjdvec_tmp, freqmodes4dates{i}.mjd];
  end
end
mjdvec = mjdvec_tmp;


if test_database == 1
  info = get_logdata4freqmode(freqmode,mjdvec,webapi_url);
else
  info = get_logdata4freqmode(freqmode,mjdvec);
end

%--------------------------------------------------------------

% filter logdata in order to decide which scans to load
%   : we here select all scans where the endlat or startlat
%     are within +-10 degree 

lat = 10;
index1 = find( abs([info.LatEnd])<lat | abs([info.LatStart])<lat);
index2 = find( [info.MJDStart]<mjd2);
index = intersect(index1,index2);
maxindex = 9; % and only load maximum maxindex of them
maxi = min(maxindex,length(index));
index = index(randperm(length(index))); %scramble around index
index = index(1:maxi);


info = info(index);
%-------------------------------------------------------------


% read scan data


urls=[info.URLS];

% {info.URL} cell array of urls
scandata = get_scan_l1b_data({urls.URL_spectra}); 

if 0
  % get ptz and o3 apriori data
  ptzdata = get_scan_aux_data({urls.URL_ptz});
  o3data =  get_scan_aux_data({urls.URL_apriori_O3}); 
  % or if you want to get several a priori data
  apriori = {'H2O','O3','O2','N2'};
  % this loop will return H2Odata,O3data,O2data, and N2 data
  for i=1:length(apriori)
    urls_apriori = eval(['{urls.URL_apriori_',apriori{i},'}']);  
    eval([apriori{i},'data = get_scan_aux_data(urls_apriori)']);
  end
end


if 0
  % also possible to for url to be a string
  url = info(1).URLS.URL_spectra;
  scandata = get_scan_l1b_data(url);
  url = info(1).URLS.URL_ptz;
  ptzdata  = get_scan_aux_data(url);
  url = info(1).URLS.URL_apriori_O3;
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
  plot( freqmat(:,okind)/1e9, scandata(i).Spectrum(:,okind ) )
  grid on
  scanmjd = (scandata(i).MJD(1)+scandata(i).MJD(end))/2;
  scandate = datestr(datenum('1858-11-17') + scanmjd,'yyyy-mm-ddTHH:MM:SS');
  scanid = num2str(scandata(i).ScanID(1));
  scanfreqmode = scandata(i).FreqMode(1);
  str = sprintf('Date: %s \nScanID: %s FreqMode: %d', scandate,scanid,scanfreqmode);
  title(str,'fontsize',8)
  xlabel('Freq. [GHz]') 
  ylabel('Tb [K]')
  ylim([-10,250])

end







