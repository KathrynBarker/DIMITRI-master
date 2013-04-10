;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_VGT_CORRECTION_FACTOR       
;* 
;* PURPOSE:
;*      RETURNS THE VGT CORRECTION FACTOR
;* 
;* CALLING SEQUENCE:
;*      RES = GET_VGT_CORRECTION_FACTOR()      
;* 
;* INPUTS:
;*      DOY      - AN INTEGER OF THE DAY OF YEAR
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      CF       - CORRECTION FACTOR FOR THE VGT2 VITO REFLECTANCE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      09 APR 2012 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      09 APR 2012 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_VGT_CORRECTION_FACTOR,DOY

;---------------------
; GET FILE LOCATION

  FILE = GET_DIMITRI_LOCATION('VGT_CORRECTION')

;---------------------  
; GET TEMPLATE

  TEMP = VGT_CORRECTION_TEMPLATE()

;---------------------  
; READ ASCII

  CFDATA = READ_ASCII(FILE,TEMPLATE=TEMP)

;---------------------  
; GET CF FOR INPUT DOY

  IDX = WHERE(CFDATA.DOY EQ DOY,COUNT)

  IF COUNT EQ 0 THEN BEGIN
  PRINT, 'GET_VGT_CORRECTION_FACTOR: ERROR, DOY NOT FOUND'
  RETURN,1.
  ENDIF

;---------------------
; RETURN FUNCTION

  cf = CFDATA.CF[IDX]
  RETURN, CF[0]

END