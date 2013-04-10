;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_VEGETATION_OZONE      
;* 
;* PURPOSE:
;*      RETIREVES THE L1B OZONE FROM A VEGETATION LOG FILE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_VEGETATION_OZONE(LOG_FILE)      
;* 
;* INPUTS:
;*      LOG_FILE   -  THE FULL PATH OF THE PRODUCTS LOG FILE     
;*
;* KEYWORDS:
;*      VERBOSE    - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      REF_OZONE  - THE INTERPOLATED WVAP GRID
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      20 APR 2011 - C KENT    - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_VEGETATION_OZONE,LOG_FILE,VERBOSE=VERBOSE

;------------------------------------------------
;CHECK FILE EXISTS

  IF STRCMP(STRING(LOG_FILE),'') THEN BEGIN
    PRINT, 'VEGETATION L1B OZONE: ERROR, NO INPUT FILES PROVIDED, RETURNING...'
    RETURN,-1
  ENDIF  

;------------------------------------------------
;CONVERT TO OZONE FILENAMES

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'VEGETATION L1B OZONE: DEFINING INPUT FILE'
  TEMP = STRLEN(LOG_FILE)
  REF_FILE = STRING(STRMID(LOG_FILE,0,TEMP-7)+'OG.HDF')

;------------------------------------------------  
; CONVERSION FACTOR

  REF_SF = 0.004
  REF_SCALE = 100

;------------------------------------------------
; RETRIEVE OZONE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'VEGETATION L1B OZONE: RETRIEVEING OZONE'
  HDF_ID = HDF_SD_START(REF_FILE,/READ)
  SDS_NAME = HDF_SD_NAMETOINDEX(HDF_ID, 'MEASURE VALUE')
  SDS_ID=HDF_SD_SELECT(HDF_ID,SDS_NAME)
  HDF_SD_GETDATA,SDS_ID,REF_OZONE
  HDF_SD_ENDACCESS, SDS_ID
  HDF_SD_END,HDF_ID
  TEMP_DIMS = SIZE(REF_OZONE)

;------------------------------------------------
; INTERPOLATE OZONE

  REF_OZONE = REBIN(REF_OZONE,TEMP_DIMS[1]*REF_SCALE,TEMP_DIMS[2]*REF_SCALE)
  RETURN,REF_OZONE*REF_SF

end