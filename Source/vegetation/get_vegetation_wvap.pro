;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_VEGETATION_WVAP      
;* 
;* PURPOSE:
;*      RETIREVES THE L1B WVAP FROM A VEGETATION LOG FILE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_VEGETATION_WVAP(LOG_FILE)      
;* 
;* INPUTS:
;*      LOG_FILE   -  THE FULL PATH OF THE PRODUCTS LOG FILE     
;*
;* KEYWORDS:
;*      VERBOSE    - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      REF_WVAP   - THE INTERPOLATED WVAP GRID
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

FUNCTION GET_VEGETATION_WVAP,LOG_FILE,VERBOSE=VERBOSE

;------------------------------------------------
;CHECK FILE EXISTS

  IF STRCMP(STRING(LOG_FILE),'') THEN BEGIN
    PRINT, 'VEGETATION L1B WVAP: ERROR, NO INPUT FILES PROVIDED, RETURNING...'
    RETURN,-1
  ENDIF  

;------------------------------------------------
;CONVERT TO OZONE FILENAMES

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'VEGETATION L1B WVAP: DEFINING INFPUT FILE'
  TEMP = STRLEN(LOG_FILE)
  REF_FILE = STRING(STRMID(LOG_FILE,0,TEMP-7)+'WVG.HDF')

;------------------------------------------------  
; CONVERSION FACTOR

  REF_SF = 0.04
  REF_SCALE = 100

;------------------------------------------------
; RETRIEVE OZONE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'VEGETATION L1B WVAP: RETRIEVEING WVAP'
  HDF_ID = HDF_SD_START(REF_FILE,/READ)
  SDS_NAME = HDF_SD_NAMETOINDEX(HDF_ID, 'MEASURE VALUE')
  SDS_ID=HDF_SD_SELECT(HDF_ID,SDS_NAME)
  HDF_SD_GETDATA,SDS_ID,REF_WVAP
  HDF_SD_ENDACCESS, SDS_ID
  HDF_SD_END,HDF_ID
  TEMP_DIMS = SIZE(REF_WVAP)

;------------------------------------------------
; INTERPOLATE OZONE

  REF_WVAP = REBIN(REF_WVAP,TEMP_DIMS[1]*REF_SCALE,TEMP_DIMS[2]*REF_SCALE)
  RETURN,REF_WVAP*REF_SF

end