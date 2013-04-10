;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_MODISA_AUX_FILES       
;* 
;* PURPOSE:
;*      RETURNS A STRING ARRAY OF MODISA L1B AUXILIARY FILES
;* 
;* CALLING SEQUENCE:
;*      RES = GET_MODISA_AUX_FILES(FILENAME,/VERBOSE)      
;* 
;* INPUTS:
;*      FILENAME - FULL PATH OF THE FILE TO BE ANALYSED      
;*
;* KEYWORDS:
;*      VERBOSE - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      AUX_FILES - A STRING ARRAY CONTAINING THE AUXILIARY FILENAME INFORMATION
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      04 DEC 2010 - C KENT    - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      04 DEC 2010 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION SUCCESSFUL, 
;*                                RESULTS EQUAL TO HDF EXPLORER/BEAM VISAT
;*      05 JAN 2011 - C KENT    - LINUX 64-BIT MACHINE IDL 8.0: COMPILATION SUCCESSFUL, 
;*                                NO APPARENT DIFFERENCES WHEN COMPARED TO WINDOWS MACHINE
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_MODISA_AUX_FILES,FILENAME,VERBOSE=VERBOSE

;------------------------------------------------
; CHECK FILENAME IS A NOMINAL INPUT

  IF FILENAME EQ '' THEN BEGIN
    PRINT, 'MODISA AUX FILES: ERROR, INPUT FILENAME INCORRECT'
    RETURN,-1
  ENDIF

;------------------------------------------------
; DEFINE OUTPUT ARRAY

  NB_AUX_FILES = 10
  AUX_FILES = STRARR(NB_AUX_FILES)

;------------------------------------------------
; START THE SD INTERFACE AND OPEN THE PRODUCT

  HDF_ID = HDF_SD_START(FILENAME,/READ)

;------------------------------------------------
; LOOP OVER AUX FILES AND RETIREVE INFORMATION

  ATT_LIST = [$
  'Reflective LUT Serial Number and Date of Last Change',$
  'Emissive LUT Serial Number and Date of Last Change',$
  'QA LUT Serial Number and Date of Last Change' $
              ]

  FOR IN_AUX=0,N_ELEMENTS(ATT_LIST)-1 DO BEGIN
    ATTR_ID = HDF_SD_ATTRFIND(HDF_ID,ATT_LIST[IN_AUX])
    IF ATTR_ID EQ -1 THEN BEGIN
      IF KEYWORD_SET(VERBOSE) THEN PRINT, 'MODISA AUX FILES: ERROR, NO ATTRIBUTE FOR -',ATT_LIST[IN_AUX]
      RETURN,1
    ENDIF
    HDF_SD_ATTRINFO,HDF_ID,ATTR_ID, DATA=TEMP
    AUX_FILES[IN_AUX] = TEMP
  ENDFOR

;------------------------------------------------
; CLOSE THE HDF FILE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'MODISA AUX FILES: RETRIEVED DATA, CLOSING PRODUCT'
  HDF_SD_END, HDF_ID

;------------------------------------------------
; POPULATE ENTIRE OUTPUT ARRAY

  AUX_FILES[3:9]='NONE'

;------------------------------------------------
; RETURN AUX DATA LIST
  
  RETURN, AUX_FILES
  
END