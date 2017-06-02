% Run calculation and send results as json to an api if target_url
% is provided. If not, write results to .mat files.
% example source url:
% http://malachite.rss.chalmers.se/rest_api/v4/freqmode_info/2015-04-01/AC2/1/7123991206/
function []=runscript(source_url, target_url, target_username, target_password)
    Q = load('/QsmrData/Q.mat');
    Q = Q.Q;

    disp(sprintf('Using Q config with freqmode %d and invmode %s', ...
                    Q.FREQMODE, Q.INVEMODE));

    % Fix paths
    Q.ARTS               = 'LD_LIBRARY_PATH="" arts';
    Q.FOLDER_WORK        = '/tmp';

    datadir              = '/QsmrData';

    investr              = Q.INVEMODE;
    investr(1)           = upper( investr(1) );
    investr(2:end)       = lower( investr(2: end) );

    Q.FOLDER_ABSLOOKUP   = fullfile( datadir, 'AbsLookup', investr );

    Q.FOLDER_FGRID       = fullfile( datadir, 'DataPrecalced', ...
                                        'Fgrid', investr );
    Q.FOLDER_ANTENNA     = fullfile( datadir, 'DataPrecalced', 'Antenna' );
    Q.FOLDER_BACKEND     = fullfile( datadir, 'DataPrecalced', 'Backend' );
    Q.FOLDER_BDX         = fullfile( datadir, 'DataPrecalced', ...
                                        'SpeciesApriori', 'Bdx' );

    Q.FOLDER_MSIS90      = fullfile( datadir, 'DataInput', 'Temperature' );

    max_retries = 5;
    retries = max_retries;
    while (retries)
        try
            LOG = webread(source_url, weboptions('ContentType', 'json', ...
                                                 'Timeout', 60))
            if ~isempty(LOG)
                break;
            end
        catch
            pause(5);
        end
        retries = retries - 1;
        if retries == 0
            disp(sprintf('Failed to get data for freqmode %s', Q.FREQMODE))
            exit(1);
        end
    end

    if Q.FREQMODE ~= LOG.Info.FreqMode
        disp(sprintf('Freqmode missmatch, Q: %s, LOG: %s', Q.FREQMODE, ...
                        LOG.Info.FreqMode))
        exit(1)
    end

    L1B = get_scan_l1b_data(LOG.Info.URLS.URL_spectra);

    [L2,L2I,L2C] = q2_inv( LOG.Info, L1B, Q);

    if nargin < 2
        save('L2.mat', 'L2');
        save('L2I.mat', 'L2I');
        save('L2C.mat', 'L2C');
    else
        if nargin < 3
            options = weboptions('MediaType','application/json', ...
                                    'Timeout', 60);
        else
            options = weboptions('MediaType','application/json', ...
                                    'Timeout', 60, 'Username', ...
                                    target_username, 'Password', ...
                                    target_password);
        end

        data = struct('L2', L2, 'L2I', L2I, 'L2C', strjoin(L2C, '\n'));
        retries = max_retries;
        while (retries)
            try
                response = webwrite(target_url, data, options);
                break;
            catch
                pause(5);
            end
            retries = retries - 1;
            if retries == 0
                disp(sprintf('Failed to post data for freqmode %s', ...
                             Q.FREQMODE))
                exit(1);
            end
        end
    end
    fclose('all');
    exit(0);
end
