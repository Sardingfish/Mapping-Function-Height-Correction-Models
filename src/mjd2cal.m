function cal=mjd2cal(mjd)
% *************************************************************************
% PURPOSE:Convert Modified Julian Day to calendar
%
% INPUT: Modified Julian Day
% 
% OUTPUT:calendar(array of 1*6)
% 
% CALL: jd2cal
%
% History: 2019/06/11 new       
% 
% Copyright (C) 2019 by Ding Junsheng, All rights reserved.
% *************************************************************************
jd=mjd+2400000.5;
cal=jd2cal(jd);
