% A demonstration how to search and extract odin data
% from the verification dataset (VDS)
%
% demo is under development


% get an overview of freqmodes currently included in VDS

url = 'http://malachite.rss.chalmers.se/rest_api/v4/vds/'
y0 = webread(url, weboptions('ContentType','json','Timeout',60));

% get an overview of which instrument/species is included for one of the freqmode
i1 = 1;
url = y0.VDS(i1).URL_collocation;
y1 = webread(url, weboptions('ContentType','json','Timeout',60));

% select one of the istrument and species and get information on for
% which dates we have collocations
url = y1.VDS(3).URL;
y2 = webread(url, weboptions('ContentType','json','Timeout',60)); 

% select one of the date and get logdata for the collocations
url = y2.VDS(1).URL;
y3 = webread(url, weboptions('ContentType','json','Timeout',60));

%select one of the scan from this date
i4 = 2;
logdata = y3.VDS(i4).OdinInfo;
logdata.URLs = y3.VDS(i4).URLS;
species = y3.VDS(i4).CollocationInfo.Species;
instrument = y3.VDS(i4).CollocationInfo.Instrument;
url2odinl1b = logdata.URLs.URL_spectra;
url2compl2 = eval(['logdata.URLs.URL_',instrument,'_',species]);

scandata = get_scan_l1b_data(url2odinl1b);
compl2 = webread(url2compl2, weboptions('ContentType','json','Timeout',60));

% compl2 happened to be aura mls




% plot data
figure
i = 1;
set(gcf,'PaperPositionMode','auto')
hFig = figure(1);
set(hFig, 'Position', [0 0 1200 600])
set(gca,'FontSize',8)

[s1,s2] = size(scandata(i).Spectrum);
lofreq = ones(s1,1) * scandata(i).Frequency.LOFreq';
IFreqmat = scandata(i).Frequency.IFreqGrid * ones(1,s2);
freqmat = lofreq + IFreqmat;
okind = find(~bitget(scandata(i).Quality,find(bitget(hex2dec('0020'),1:8))));
subplot(1,2,1)
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

c1 = subplot(1,2,2)
semilogy(compl2.data_fields.L2gpValue*1e6,compl2.geolocation_fields.Pressure)
set(c1,'ydir','reverse');
xlabel('VMR [ppmv]')
ylabel('Pressure [hPa]')
title([instrument,': ',species])
grid on





