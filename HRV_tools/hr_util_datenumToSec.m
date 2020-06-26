function y_t = hr_util_datenumToSec(x_t)
    y_t = x_t.*(24*3600);
    y_t = y_t- y_t(1);
end
