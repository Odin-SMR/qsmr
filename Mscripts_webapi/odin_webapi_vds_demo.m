% A demonstration how to search and extract odin data
% from the verification dataset (VDS)
%
% demo is under development


% get an overview of freqmodes currently included in VDS

% Backend    Freqmode    Instrument     Species
%-----------------------------------------------------
% AC1        2           SMILES         O3, HNO3 
%                        MLS            O3, HNO3  
%                        MIPAS          O3, HNO3
%-----------------------------------------------------
% AC1        13          SMILES         O3
%                        MLS            O3, H2O
%                        MIPAS          O3, H2O
%-----------------------------------------------------
% AC1        19          SMILES         O3
%                        MLS            O3, H2O
%                        MIPAS          O3, H2O
%----------------------------------------------------- 
% AC1        21          SMILES         O3, NO
%                        MLS            O3, H2O
%                        MPIAS          O3, H2O
%-----------------------------------------------------
% AC2        1           SMILES         O3
%                        MLS            O3, ClO, N2O
%                        MIPAS          O3, N2O
%-----------------------------------------------------
% AC2        8           SMILES         O3
%                        MLS            O3, H2O
%                        MIPAS          O3, H2O
%-----------------------------------------------------
% AC2        14          SMILES         O3
%                        MLS            O3, CO
%                        MIPAS          O3, CO
%-----------------------------------------------------
% AC2        17          SMILES         O3
%                        MLS            O3, H2O
%                        MIPAS          O3, H2O
%
%

% select one freqmode/instrument/species
clear
freqmode = 1;
instrument = 'MLS';
species = 'O3';


url = 'http://malachite.rss.chalmers.se/rest_api/v4/vds/';
y0 = webread(url, weboptions('ContentType','json','Timeout',60));
VDS = y0.VDS;

% get an overview of which instrument/species is included for each  freqmode
for i1 = 1:length(VDS)
  url = VDS(i1).URL_collocation;
  y1 = webread(url, weboptions('ContentType','json','Timeout',60));
  VDS(i1).comp = y1.VDS;
end

% select the desired data
for i = 1:length(VDS)
  for j = 1:length(VDS(i).comp)
     if ( VDS(i).FreqMode==freqmode & ...
          isequal( VDS(i).comp(j).Instrument, lower(instrument) ) & ...
          isequal( VDS(i).comp(j).Species, species) )
        i1 = i;
        i2 = j;
     end
  end
end

VDS = VDS(i1).comp(i2);


% get the dates where we have collocations

url = VDS.URL;
y2 = webread(url, weboptions('ContentType','json','Timeout',60));

% load scaninfo for one of the date

scramble = randperm( length(y2.VDS) );
i2 = scramble(1);
VDS = y2.VDS(i2);
url = VDS.URL;
y3 = webread(url, weboptions('ContentType','json','Timeout',60));
VDS = y3.VDS;


%select and get two scan from this date

n = 1;

for i3 = 1 : 2

  ldata = VDS(i3).OdinInfo;
  ldata.URLs = VDS(i3).URLS;
  logdata(n) = ldata;

  url2odinl1b = logdata(n).URLs.URL_spectra;
  url2compl2 = eval(['logdata(n).URLs.URL_',lower(instrument),'_',species]);

  scandata(n) = get_scan_l1b_data(url2odinl1b);
  compl2(n) = webread(url2compl2, weboptions('ContentType','json','Timeout',60));
  n = n + 1;

end

% plot data
figure
set(gcf,'PaperPositionMode','auto')
hFig = figure(1);
set(hFig, 'Position', [0 0 1200 600])
set(gca,'FontSize',8)

s0 = length(scandata);
for i = 1:s0

  [s1,s2] = size(scandata(i).Spectrum);
  lofreq = ones(s1,1) * scandata(i).Frequency.LOFreq';
  IFreqmat = scandata(i).Frequency.IFreqGrid * ones(1,s2);
  freqmat = lofreq + IFreqmat;
  okind = find(~bitget(scandata(i).Quality,find(bitget(hex2dec('0020'),1:8))));
  subplot(s0,2,1 + 2*(i-1))
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

  c1 = subplot(s0,2,2 + 2*(i-1));

  if isequal(instrument,'MLS');

     semilogy(compl2(i).data_fields.L2gpValue*1e6,compl2(i).geolocation_fields.Pressure)
     set(c1,'ydir','reverse');
     xlabel('VMR [ppmv]')
     ylabel('Pressure [hPa]')
     title([instrument,': ',species])
     grid on
 
  elseif isequal(instrument,'SMILES');
     
     plot(compl2(i).data_fields.L2Value*1e6,compl2(i).geolocation_fields.Altitude)
     xlabel('VMR [ppmv]')
     ylabel('Altitude [Km]')
     title([instrument,': ',species])
     grid on
 
  elseif isequal(instrument,'MIPAS');

     semilogy(compl2(i).target,compl2(i).pressure)
     set(c1,'ydir','reverse');
     xlabel('VMR [ppmv]')
     ylabel('Pressure [hPa]')
     title([instrument,': ',species])
     grid on 

  end

end




