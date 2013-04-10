;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      CONVERT_WAVELENGTH_TO_DINDEX       
;* 
;* PURPOSE:
;*      RETURNS THE DIMITRI BAND INDEX FOR A GIVEN WAVELENGTH. NOTE, 
;*      DIMITRI BAND INDEXES RANGE START FROM 1, SENSOR INDEXES START FROM 0.
;* 
;* CALLING SEQUENCE:
;*      RES = CONVERT_WAVELENGTH_TO_DINDEX(WAVELENGTH)      
;* 
;* INPUTS:
;*      WAVELENGTH- A STRING OF THE WAVELENGTH TO BE CONVERTED (E.G. '555')
;*
;* KEYWORDS:
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TMP_IDX   - AN INTEGER OF THE DIMITRI BAND INDEX
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      14 MAR 2011 - C KENT   - DIMITRI-2 V1.0
;*      21 MAR 2011 - C KENT   - MODIFIED FILE DEFINITION TO USE GET_DIMITRI_LOCATION
;*
;* VALIDATION HISTORY:
;*      14 APR 2011 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION CONVERT_WAVELENGTH_TO_DINDEX,WAVELENGTH,VERBOSE=VERBOSE

;------------------------------------
; DEFINE SENSOR FILE
  
  SBI_FILE = GET_DIMITRI_LOCATION('BAND_INDEX')  
  RES       = FILE_INFO(SBI_FILE)
  IF RES.EXISTS EQ 0 THEN BEGIN
    if keyword_set(verbose) then PRINT, 'WAVELENGTH_TO_DINDEX: ERROR, SENSOR INFORMATION FILE NOT FOUND'
    RETURN,-1
  ENDIF

;------------------------------------
; RETRIEVE TEMPLATE AND READ DATA FILE  
  
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'WAVELENGTH_TO_DINDEX: RETRIEVING AUX FILE TEMPLATE'  
  TEMP = GET_DIMITRI_BAND_INDEX_TEMPLATE()
  BI_DATA = READ_ASCII(SBI_FILE,TEMPLATE=TEMP)

  TMP_IDX = WHERE(BI_DATA.(1) EQ WAVELENGTH)
  IF TMP_IDX[0] EQ -1 THEN BEGIN
    if keyword_set(verbose) then PRINT, 'WAVELENGTH_TO_DINDEX: ERROR, COULD NOT FIND WAVELENGTH MATCH'
    RETURN,-1
  ENDIF

;------------------------------------
; RETURN THE BAND INDEX 
  
  RETURN,TMP_IDX

END