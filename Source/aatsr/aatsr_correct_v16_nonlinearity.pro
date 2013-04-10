;FILE: AATSR_CORRECT_V16_NONLINEARITY.PRO
;FUNCTION:
;       If GC1 filename = ATS_GC1_AXVIEC20020123_073430_20020101_000000_20200101_000000 then
;       no nonlinearity correction is NOT applied to 1.6um channel. The function then applies the correction
;       to the uncorrected data.  This method is described in detail in PO-TN-RAL-AT-0539 Issue 1.1
;
;ORIGINAL: Dave Smith RAL SSTD,  17-Jan-2008
;
;MODIFICATION: Dave Smith RAL SSTD, 30-Jul-2008 
;              Correction to account for scaling of 1.6um reflectance values which should be 0-1. Previous version worked on range 0-100%.
;
;IMPORT:
;       GC1_FILENAME - String containing name of GC1 filename associated with L1B product - DSD31 in product
;       V16_UNCORRECTED - Variable containing 1.6um reflectance values from L1B product. The value(s) must be a
;                         in the range 0-1
;
;EXPORT:
;       V16_CORRECTED - Corrected 1.6um Refelectance. If no correction is needed then the input value is returned
;
;*************************************************************************************
FUNCTION AATSR_CORRECT_V16_NONLINEARITY,GC1_FILENAME,V16_UNCORRECTED

;Nonlinearity coefficients from pre-launch calibration
    A = [-0.000027,-0.1093,0.009393,0.001013]

;Find out which nonlinearity correction has been applied - uses name of GC1 file

;Nonlinearity Correction NOT applied
   IF(GC1_FILENAME EQ 'ATS_GC1_AXVIEC20020123_073430_20020101_000000_20200101_000000')THEN BEGIN

;Convert 1.6um reflectance back to raw signal using linear conversion
      VOLTS = V16_UNCORRECTED/0.192*(-0.816)

;Convert 1.6um raw signal to reflectance using non-linear conversion function
      V16_CORRECTED = !PI*(A(0)+A(1)*VOLTS+A(2)*VOLTS^2+A(3)*VOLTS^3)/1.553


;Nonilinearity Correction Already Applied
   ENDIF ELSE BEGIN
        V16_CORRECTED = V16_UNCORRECTED
   ENDELSE

RETURN,V16_CORRECTED
END