function [L2, L2I] = run_qsmr(URI)
    LOG = get_scan_log(URI);
    fm = LOG.Info.FreqMode;
    L1B = get_scan_l1b_data(LOG.Info.URLS.URL_spectra);
    [L2, L2I] = q2_inv(LOG.Info, L1B, q_std(fm));
