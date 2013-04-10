;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_PARASOL_L1B_PIXEL_STRUCTURE       
;* 
;* PURPOSE:
;*      RETURNS THE PARASOL PIXEL STRUCTURE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_PARASOL_L1B_PIXEL_STRUCTURE(INUM_RECS)      
;* 
;* INPUTS:
;*      INUM_RECS - NUMBER OF PIXELS THE STRUCTURE IS TO BE MADE FOR 
;*
;* KEYWORDS:
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      L1B_PIXEL - A STRUCTURE OF THE PARASOL PIXEL 
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      15 DEC 2010 - C KENT   - DIMITRI-2 V1.0
;*      29 FEB 2012 - C KENT   - ADDED SEQUENCE NUMBER FIELD
;*
;* VALIDATION HISTORY:
;*      10 JAN 2011 - C KENT   - WINDOWS 32 BIT MACHINE, IDL 7.1: COMPILATION AND 
;*                               RUNNING SUCCESSFUL, RESULTS NOMINAL 
;*                             - LINUX 64-BIT MACHINE, IDL 8.0: COMPILATION SUCESSFUL, 
;*                               RESULTS EQUAL TO WINDOWS MACHINE
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_PARASOL_L1B_PIXEL_STRUCTURE,INUM_RECS,VERBOSE=VERBOSE

;------------------------------------------------
; DEFINE A PIXEL STRUCTURE
  
  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'PARASOL L1B PIXEL: COMPUTING STRUCTURE FOR PIXELS = ',INUM_RECS
  TEMP_FLT_ARR = FLTARR(16)
  TEMP_INT_ARR = INTARR(16)
  TEMP_FLT = 0.0
  TEMP_INT = 0

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'PARASOL L1B PIXEL: DEFINING STRCUTURE'
  L1B_PIXEL = {$
              LINE            : TEMP_FLT    ,$
              COLUMN          : TEMP_FLT    ,$
              LATITUDE        : TEMP_FLT    ,$
              LONGITUDE       : TEMP_FLT    ,$
              SAA             : TEMP_FLT    ,$
              NUM_DIR         : TEMP_INT    ,$
              SZA             : TEMP_FLT_ARR,$
              VZA             : TEMP_FLT_ARR,$
              RAA             : TEMP_FLT_ARR,$
              DELTA_AV_COS_A  : TEMP_FLT_ARR,$
              DELTA_AV_SIN_A  : TEMP_FLT_ARR,$
              REF_443NP       : TEMP_FLT_ARR,$
              REF_490P        : TEMP_FLT_ARR,$
              REF_1020NP      : TEMP_FLT_ARR,$
              REF_565NP       : TEMP_FLT_ARR,$
              REF_670P        : TEMP_FLT_ARR,$
              REF_763NP       : TEMP_FLT_ARR,$
              REF_765NP       : TEMP_FLT_ARR,$
              REF_865P        : TEMP_FLT_ARR,$
              REF_910NP       : TEMP_FLT_ARR,$
              REF_490P_Q      : TEMP_FLT_ARR,$
              REF_670P_Q      : TEMP_FLT_ARR,$
              REF_865P_Q      : TEMP_FLT_ARR,$
              REF_490P_U      : TEMP_FLT_ARR,$
              REF_670P_U      : TEMP_FLT_ARR,$
              REF_865P_U      : TEMP_FLT_ARR,$
              SEQ_NUMBER      : TEMP_INT_ARR $
              }

;----------------------------------------------
; REPLICATE PIXEL STRUCTURE FOR THE NUMBER OF PIXELS

  IF INUM_RECS GT 1 THEN BEGIN 
    L1B_PIXEL=REPLICATE(L1B_PIXEL,INUM_RECS)
  ENDIF
  
;-----------------------------------------------
; RETURN STRUCTURE  
  
  RETURN,L1B_PIXEL

END