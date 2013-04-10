;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_SITE_TYPE       
;* 
;* PURPOSE:
;*      RETURNS THE TYPE OF SURFACE OF A VALIDATION SITE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_SITE_TYPE(SITE_ID)      
;* 
;* INPUTS:
;*      SITE_ID = A STRING CONTAINING THE NAME OF THE REQUIRED SITE TYPE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TYPE  - A STRING OF THE VALIDATION SITE TYPE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      06 APR 2010 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      23 DEC 2010 - C KENT   - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION AND CALLING SUCCESSFUL
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_SITE_TYPE,SITE_ID,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'SITE_TYPE: RETRIEVING TYPE FOR SITE - ',SITE_ID

;-----------------------------
; CHECK FILE EXISTS

  SITE_FILE = GET_DIMITRI_LOCATION('SITE_DATA')
  TEMP = FILE_INFO(SITE_FILE)
  IF TEMP.EXISTS EQ 0 THEN BEGIN
    PRINT, 'SITE_TYPE: ERROR, SITE FILE DOES NOT EXIST'
    RETURN,-1
  ENDIF

;-----------------------------
; GET TEMPLATE FOR SITE FILE

  IF KEYWORD_SET(VERBOSE) THEN SITE_TEMPLATE = GET_DIMITRI_SITE_DATA_TEMPLATE(/VERBOSE) $
  ELSE SITE_TEMPLATE = GET_DIMITRI_SITE_DATA_TEMPLATE()

;-----------------------------
; READ FILE
  
  SITE_DATA = READ_ASCII(SITE_FILE,TEMPLATE=SITE_TEMPLATE)

  RES = WHERE(STRCMP(SITE_DATA.SITE_ID,SITE_ID) EQ 1)
  IF RES[0] EQ -1 OR N_ELEMENTS(RES) GT 1 THEN BEGIN
    PRINT,'SITE_TYPE: ERROR, SITE_ID ERROR IN SITE_FILE' 
    RETURN,-1
  ENDIF

;-----------------------------  
; RETRIEVE COORDINATES

  TYPE = SITE_DATA.TYPE[RES]

;-----------------------------
; RETURN COORDINATES
  
  RETURN,TYPE

END