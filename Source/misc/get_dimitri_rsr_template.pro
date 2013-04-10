;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_RSR_TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS THE DIMITRI RSR FILE TEMPLATE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_RSR_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      RSR_TEMPLATE  - A TEMPLATE FOR READING THE DIMITRI SITE FILE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      26 DEC 2010 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      14 APR 2011 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_RSR_TEMPLATE,VERBOSE=VERBOSE

    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI SPECTRAL RESPONSE TEMPLATE: RETRIEVING TEMPLATE'
    
    TEMP_NAME     = ['WAVELENGTH','RESPONSE']
    TEMP_TYPE     = [4,4]
    RSR_TEMPLATE  = {VERSION        : 1.0                       , $
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
    RETURN, RSR_TEMPLATE

END