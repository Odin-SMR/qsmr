% Function for returning sideband leakage for the provided L1b struct
%
%
% Function implements leakage function (10) from [1] with temperature
% dependent path length as in (20), but with updated parameters.
%
% OUT   sb_leakage  Sideband filter leakage for input frequencies for
%                   all spectra in scan
%
% IN    L1b         L1b struct (assumes v5 of API though v4 might work)
%
%       freq_grid   OPTIONAL. If freq_grid is supplied, leakage will be
%                   calculated only for the given frequencies.
%                   Additionally, this will result in only one leakage
%                   profile for the entire scan, using the median Tcal
%                   LOFreq and SBPath values for scan.
%
% Created:  2017-08-29  andreas.skyman@molflow.com
% Updated:  2017-12-13  andreas.skyman@molflow.com
%
% --------
% [1]:  Post launch characterisation of Odin-SMR sideband filter properties,
%   P. Eriksson and J. Urban, Chalmers University of Technology (2006-08-30)


function sb_leakage = sband_from_l1b(l1b, freq_grid)

    if isfield(l1b, 'Data')
      scan = l1b.Data;
    else
      scan = l1b;
    end
    rows = length(scan.Frequency.IFreqGrid);
    cols = length(scan.Frequency.LOFreq);

    % If no freq_grid is supplied, calculate leakage for all spectra:
    if nargin < 2

        freq_grid = ...
            repmat(scan.Frequency.IFreqGrid, 1, cols) ...
            + repmat(scan.Frequency.LOFreq', rows, 1);

    % If freq_grid is supplied, calculate only one leakage profile:
    else

        rows = 1;

    end

    % Parameters from analysis, possibly overridden in switch below:
    % (N.B.: these parameters are preliminary and will change!)
    temp_coeff = 1.041477e-6;
    % When assuming l0_SB for FM8 from "The Spread Sheet":
    % temp_coeff = 0.863415e-6;
    T0 = 291.0;

    % FreqMode specific parameters:
    % (N.B.: the assumed r0 values are almost definitely wrong!)
    switch(scan.FreqMode(1))

        % 495 GHz frontend:
        case 8

            % From report [1]:
            r0 = 10.0 ^ (-26.7 / 10.0);
            % l0_LO = 0.5 * 38.635e-3;

            % From parameter estimation:
            l0_SB = 9.469150e-3;

            % Calculated from "The Spread Sheet":
            l0_LO = 0.5 * 38.6344711882e-3;
            % l0_SB = 9.46777457791e-3;

        case 17

            % From report [1]:
            r0 = 10.0 ^ (-26.7 / 10.0);
            % l0_LO = 0.5 * 38.517e-3;

            % Calculated from "The Spread Sheet":
            l0_LO = 0.5 * 38.5162897e-3;
            l0_SB = 9.46857612633e-3;

        case 1

            % From report [1]:
            r0 = 10.0 ^ (-26.7 / 10.0);
            % l0_LO = 0.5 * 38.237e-3;

            % Calculated from "The Spread Sheet":
            l0_LO = 0.5 * 38.2363953829e-3;
            l0_SB = 9.77324838062e-3;

        % 549 GHz frontend (experimental):
        case 19

            % From report [1]:
            r0 = 10.0 ^ (-11 / 10.0);
            % l0_LO = 0.5 * 38.237e-3;
            % l0_SB = 0.5 * 19.378e-3;

            % Calculated from "The Spread Sheet":
            l0_LO = 0.5 * 38.21672666e-3;
            l0_SB = 9.8280425e-3;

        case 21

            % From report [1]:
            r0 = 10.0 ^ (-14.4 / 10.0);
            l0_LO = 0.5 * 38.237e-3;
            l0_SB = 0.5 * 19.021e-3;

        case 2

            % From report [1]:
            r0 = 10 ^ (-14.4 / 10.0);

            % Calculated from "The Spread Sheet":
            l0_LO = 0.5 * 38.5327444025e-3;
            l0_SB = 9.56785493557e-3;

        % 555 GHz frontend (experimental):
        case 13

            % From report [1]:
            r0 = 10 ^ (-12 / 10.0);

            % Calculated from "The Spread Sheet":
            l0_LO = 0.5 * 38.2132275512e-3;
            l0_SB = 9.65740372371e-3;

        otherwise

            % Cannot guess filter for other Freqmodes, so throw error:
            throw(MException( ...
                'sband_from_l1b:FreqmodeUndefinedError', ...
                'Sideband filter settings undefined for FreqMode %d', ...
                    scan.FreqMode) ...
            );

    end

    % Construct parameters struct:
    params = struct( ...
        'l0_SB', l0_SB, ...
        'temp_coeff', temp_coeff, ...
        'T0', T0, ...
        'r0', r0, ...
        'l0_LO', l0_LO, ...
        'rows', rows, ...
        'cols', cols ...
    );

    % Calculate leakage:
    sb_leakage = leakage(freq_grid, params, scan);

end


function leak = leakage(f_main, params, scan)
    % Calculate the sideband leakage for the given main band
    % frequencies, parameters and L1b data.

    if params.rows == 1

        f_image = 2 * median(scan.Frequency.LOFreq) - f_main;
        leak = (response_tot(f_image, params, scan) ./ ( ...
            response_tot(f_main, params, scan) ...
            + response_tot(f_image, params, scan) ...
        ));

    else

        f_image = 2 * repmat(scan.Frequency.LOFreq', params.rows, 1) - f_main;
        leak = (response_tot(f_image, params, scan) ./ ( ...
            response_tot(f_main, params, scan) ...
            + response_tot(f_image, params, scan) ...
        ));

    end

    leak = leak .* (leak > 0);

end


function r_tot = response_tot(freq, params, scan)
    % Calculate total response function for the given frequencies,
    % parameters and L1b data

    r_tot = response_sb(freq, params, scan) ...
        .* response_lo(freq, params, scan);

end


function r_lo = response_lo(freq, params, scan)
    % Calculate the response of the LO injection for given frequencies,
    % parameters and L1b data


    if params.rows == 1

        r_lo = response(freq, params.r0, path_length( ...
            params.l0_LO, ...
            0, ...
            median(scan.Tcal) - params.T0, ...
            params.temp_coeff ...
        ));

    else

        r_lo = response(freq, params.r0, path_length( ...
            params.l0_LO, ...
            0, ...
            repmat(scan.Tcal', params.rows, 1) - params.T0, ...
            params.temp_coeff ...
        ));

    end

end


function r_sb = response_sb(freq, params, scan)
    % Calculate the sideband filter response for given frequencies,
    % parameters and L1b data

    if params.rows == 1

        r_sb = response(freq, params.r0, path_length( ...
            params.l0_SB, ...
            median(scan.SBpath), ...
            median(scan.Tcal) - params.T0, ...
            params.temp_coeff ...
        ));

    else

        r_sb = response(freq, params.r0, path_length( ...
            params.l0_SB, ...
            repmat(scan.SBpath', params.rows, 1), ...
            repmat(scan.Tcal', params.rows, 1) - params.T0, ...
            params.temp_coeff ...
        ));

    end

end


function resp = response(freq, r0, l0)
    % Calculate response for given frequencies, maximum supression and
    % interferometer (single) path length

    C0 = 299792458.0;
    resp = r0 + 0.5 * (1 - 2 * r0) * (1 + cos(2 * pi * 2 * l0 .* freq / C0));

end


function l = path_length(l_0, l_sb, temp, temp_coeff)
    % Get total (single) path length for sideband filter based on
    % (single) rest length, (double) sideband path tuning length,
    % temperature and thermal expansion coefficient

    l = l_0 + l_sb / 2 + temp_coeff * temp;

end
