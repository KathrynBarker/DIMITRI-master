
;FILE: AATSR_REMOVE_DRIFT_CORRECTION.PRO
;DESCRIPTION
; Identifies which calibration drift correction is used in AATSR L1B reflectance
;
; VC1 file generation date indicates which drift correction has been applied.
;     Date before 29-Nov-2005 13:20:26  then no correction applied
;     Date between 29-Nov-2005 13:20:26 and 18-Dec-2006 20:14:15 then exponential drift correction is applied
;     Date after 18-Dec-2006 20:14:15 then thin film correction is applied
;
;ORIGINAL: 16-Jan-2008
;
;MODIFICATION:  14-July-2010 - Following a system crash on 4th April 2010 - All VC1 files generated over the period 
;               between 04-April-2010 and 12-July-2010 inclusive did NOT contain any drift correction - hence this function was 
;               incorrectly removing the corrections.  A fix has been implemented to perform no modification to L1b reflectances
;               where VC1 files generated during that period.
;
;IMPORT: VC1_FILENAME - String containing name of GC1 filename associated with L1B product - DSD31 in product
;        ACQ_TIME - String containing acquistion time of product - format = DD-MMM-YYYY HH:MM:SS
;        ICH - Integer Variable Containing Channel Number to be processed
;               0 = 555nm
;               1 = 659nm
;               2 = 870nm
;               3 = 1600nm
;        REFLECTANCE - Variable containing reflectance reading from L1B product
;
;EXPORT: UNCORRECTED - Variable containing reflectance reading with drift correction removed.  If an invalid
;                      channel is specified or the date precedes the launch then an error is reported and -1 is
;                      set as the return value
;
;***************************************************************************************************************
FUNCTION AATSR_REMOVE_DRIFT_CORRECTION,VC1_FILENAME,ACQ_TIME,ICH,REFLECTANCE

    V56 = 0
    V66 = 1
    V87 = 2
    V16 = 3

    ERROR = -1

    IF(ICH GT 3)THEN BEGIN
       PRINT,'ERROR: Channel out of range - no correction applied'
       RETURN,ERROR        ;Return error value
    ENDIF

    MONTHSTR = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

    T0 = TIMESTR_TO_JULDAY('01-MAR-2002 00:00:00') ;Envisat launch date - converted to julian time
    T = TIMESTR_TO_JULDAY(ACQ_TIME)                ;Image acquisition time - converted to julian time

    IF(T LT T0)THEN BEGIN
       PRINT,'ERROR: Acquisition time before ENVISAT launch date = ',ACQ_TIME
       RETURN,ERROR
    ENDIF

    K = [0.034, 0.021, 0.013, 0.002]                ;yearly drift rates for exponential drift

    A = [[0.083,  1.5868E-3], $                    ;Thin film drift model coefficients
         [0.056,  1.2374E-3], $
         [0.041,  9.6111E-4] ]

;******************************************************************************************************************************
;Find out which drift correction has been applied - uses date of VC1
;VC1 time
   year = strmid(vc1_filename,14,4)
   month = monthstr(fix(strmid(vc1_filename,18,2))-1)
   day = strmid(vc1_filename,20,2)
   hour = strmid(vc1_filename,23,2)
   mins = strmid(vc1_filename,25,2)
   secs = strmid(vc1_filename,27,2)

   PROC_TIME = DAY+'-'+MONTH+'-'+YEAR+' '+HOUR+':'+MINS+':'+SECS
   PROC_TIME = TIMESTR_TO_JULDAY(PROC_TIME)

;Now Identify Which Correction Has Been Applied
   IF((PROC_TIME LT TIMESTR_TO_JULDAY('29-NOV-2005 13:20:26')) OR $
      ((PROC_TIME GE TIMESTR_TO_JULDAY('04-APR-2010 00:00:00')) AND $
       (PROC_TIME LT TIMESTR_TO_JULDAY('13-JUL-2010 00:00:00'))) $
      )THEN BEGIN
     CORRECTION = 0     ;NO Drift Correction Applied
     
   ENDIF ELSE IF((PROC_TIME GE TIMESTR_TO_JULDAY('29-NOV-2005 13:20:26')) AND $
                 (PROC_TIME LT TIMESTR_TO_JULDAY('18-DEC-2006 20:14:15')) $
                )THEN BEGIN
     CORRECTION = 1     ;Exponential Drift Correction is Applied
   ENDIF ELSE BEGIN
     CORRECTION = 2     ;Thin Film Drift Correction is Applied
   ENDELSE

;Now remove corrections if applied

;No correction applied
        IF(CORRECTION EQ 0)THEN $
           DRIFT = 1.0


;Exponential drift correction
        IF(((ICH EQ V16) AND (CORRECTION NE 0)) OR $
           ((ICH NE V16) AND (CORRECTION EQ 1)))THEN $
           DRIFT = EXP(K(ICH)*(T-T0)/365.0)


;Thin film correction
        IF(((ICH NE V16) AND (CORRECTION EQ 2)))THEN $
           DRIFT = 1.0 + A(0,ICH)*SIN(A(1,ICH)*(T-T0))^2


;Now multiply reflectance by drift to get uncorrected value
       UNCORRECTED = REFLECTANCE*DRIFT

;And we are done
RETURN,UNCORRECTED
END