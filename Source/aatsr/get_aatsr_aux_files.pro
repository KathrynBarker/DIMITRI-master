;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_AATSR_AUX_FILES       
;* 
;* PURPOSE:
;*      RETURNS A STRING ARRAY OF AATSR L1B AUXILIARY FILES
;* 
;* CALLING SEQUENCE:
;*      RES = GET_AATSR_AUX_FILES(FILENAME,/VERBOSE)      
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
;*      None
;*
;* MODIFICATION HISTORY:
;*      10 DEC 2010 - C KENT    - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      13 DEC 2010 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION SUCCESSFUL,
;*                                AUX FILE DATA NOMINAL FOR AATSR L1B PRODUCT
;*                                (VALIDATED AGAINST BEAM and TEXTPAD)
;*      06 JAN 2010 - C KENT    - LINUX 64-BIT MACHINE IDL 8.0: COMPILATION SUCCESSFUL,
;*                                VALUES EQUAL TO WINDOWS 32-BIT MACHINE
;*
;**************************************************************************************
;**************************************************************************************
FUNCTION GET_AATSR_AUX_FILES,FILENAME,VERBOSE=VERBOSE

;------------------------------------------------
; CHECK FILENAME IS A NOMINAL INPUT

  IF FILENAME EQ '' THEN BEGIN
    PRINT, 'AATSR L1B AUX FILES: ERROR, INPUT FILENAME INCORRECT'
    RETURN,-1
  ENDIF

;------------------------------------------------
; DEFINE HEADER VARIABLES

  MPH_SIZE = 1247
  SPH_SIZE = 12830
  FILE_MPH = BYTARR(MPH_SIZE)
  FILE_SPH = BYTARR(SPH_SIZE)
  
;-----------------------------------------------
; OPEN THE FILE AND EXTRACT HEADER

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'AATSR L1B AUX FILES: OPENING PRODUCT'
  OPENR,PRD_AUX,FILENAME,/GET_LUN
  READU,PRD_AUX,FILE_MPH
  READU,PRD_AUX,FILE_SPH
  
;-----------------------------------------------
; DEFINE OUTPUT ARRAY

  NB_AUX_FILES = 10
  AUX_FILES = STRARR(NB_AUX_FILES)

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'AATSR L1B AUX FILES: RETRIEVING DSD INFORMATION'
  AUX_DSD_POS =STRPOS(FILE_SPH,'DS_NAME="AATSR_SOURCE_PACKETS        "') 
  
;----------------------------------------
; POINT TO THE MDS WITHIN THE FILE AND EXTRACT THE DATA
    
  POINT_LUN, PRD_AUX, AUX_DSD_POS+MPH_SIZE
  AUX_DSD = BYTARR(280)
    
  FOR I=0,NB_AUX_FILES-1 DO BEGIN
    READU,PRD_AUX,AUX_DSD
    AUX_DSD_STR = STRING(AUX_DSD)
    AUX_FNAME_POS = STRPOS(AUX_DSD_STR,'FILENAME=')
    AUX_FILES[I]  = STRMID(AUX_DSD_STR,AUX_FNAME_POS+10,62)
  ENDFOR
  
;---------------------------------------
; CLOSE THE FILE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'AATSR L1B AUX FILES: CLOSING PRODUCTS AND RELEASING THE LUN'
  CLOSE, PRD_AUX
  FREE_LUN, PRD_AUX

;---------------------------------------
; RETURN ARRAY OF AUXILIARY DATA FILES

  RETURN,AUX_FILES

END