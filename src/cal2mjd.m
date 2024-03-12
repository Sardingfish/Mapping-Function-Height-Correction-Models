function mjd=cal2mjd(cal)
% *************************************************************************
% PURPOSE:Convert calendar to Modified Julian Day
%
% INPUT: calendar(array of 1*6)
% 
% OUTPUT:Modified Julian Day
% 
% CALL: cal2jd
%
% History: 2019/06/11 new       
% 
% Copyright (C) 2019 by Ding Junsheng, All rights reserved.
% *************************************************************************
jd = cal2jd(cal);
mjd = jd - 2400000.5;
