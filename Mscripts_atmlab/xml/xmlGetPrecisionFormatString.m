% Returns the proper format string for the given precision.
%
%    Precision could be either the number of digits or a string of value
%    FLOAT or DOUBLE
%
% FORMAT   format = xmlGetPrecisionFormatString(precision)
%
% OUT   format     Format string for printf
% IN    precision  Digits

% 2004-03-08  Created by Oliver Lemke.

function format = xmlGetPrecisionFormatString(precision)

if (strcmpi (precision, 'FLOAT'))
  precision = 7;
elseif (strcmpi (precision, 'DOUBLE'))
  precision = 15;
else
  error('Invalid precision: %s', precision);
end

format = sprintf ('%%1.%de', precision);

