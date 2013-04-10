FUNCTION JULDAY_TO_TIMESTR,JDAY
;*** Converts time string with format 'DD-MMM-YYYY HH:MM:SS' to julian days ***
; CODE PROVIDED BY D. SMITH, RAL.
    caldat,jday,mon,day,year,hrs,mins,secs
    months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
    timestr = string(day,format='(i2.2)') + '-' + $
             months(mon-1) + '-' + $
             string(year,format='(i4.4)') + ' ' + $
             string(hrs,format='(i2.2)') + ':' + $
             string(mins,format='(i2.2)') + ':' + $
             string(secs,format='(i2.2)')
    return,timestr
END