;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      VGT_CORRECTION_TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS THE DIMITRI VGT CORRECTION TEMPLATE
;* 
;* CALLING SEQUENCE:
;*      RES = VGT_CORRECTION_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TEMPLATE - A TEMPLATE FOR READING THE VGT CORRECTION FILE
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

FUNCTION VGT_CORRECTION_TEMPLATE,VERBOSE=VERBOSE

    IF KEYWORD_SET(VERBOSE) THEN PRINT,'VGT_CORRECTION_TEMPLATE: RETRIEVING TEMPLATE'
    
    TEMP_NAME     = ['DOY','CF']
    TEMP_TYPE     = [3,4]
    TEMPLATE      = {VERSION        : 1.0                       , $
                     DATASTART      : 1 , $
                     DELIMITER      : ';' , $
                     MISSINGVALUE   : !VALUES.F_NAN, $
                     COMMENTSYMBOL  : ''          , $
                     FIELDCOUNT     : N_ELEMENTS(TEMP_NAME), $
                     FIELDTYPES     : TEMP_TYPE, $
                     FIELDNAMES     : TEMP_NAME, $
                     FIELDLOCATIONS : INDGEN(N_ELEMENTS(TEMP_NAME)), $
                     FIELDGROUPS    : [INDGEN(N_ELEMENTS(TEMP_NAME))]}
    
   ; IF KEYWORD_SET(VERBOSE) THEN HELP,RSR_TEMPLATE       
    RETURN, TEMPLATE

END