;FILE:  TIMESTR_TO_JULDAY.PRO
;FUNCTION: Converts timestring with format 'DD-MMM-YYYY HH:MM:SS' to julian day
;MODDIFICATION: 18-JAN-2008 - Updated to work on arrays of timestrings
;
;******************************************************************************************************
FUNCTION TIMESTR_TO_JULDAY,TIMESTR

    months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

    NP = N_ELEMENTS(TIMESTR)

    IF(NP GT 1)THEN $
       JDAY = DBLARR(NP) $
    ELSE $
       JDAY = 0.0D

    FOR I = 0, NP-1 DO BEGIN
       day = fix(strmid(timestr(i),0,2))
       mon = strupcase(strmid(timestr(i),3,3))
       year = fix(strmid(timestr(i),7,4))
       hrs = fix(strmid(timestr(i),12,2))
       mins = fix(strmid(timestr(i),15,2))
       secs = fix(strmid(timestr(i),18,2))
       jday(i) = julday(where(months eq mon)+1,day,year,hrs,mins,secs)
    ENDFOR

    RETURN,JDAY

END