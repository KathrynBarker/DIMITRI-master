;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_SITE_DATA_TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS AN ARRAY OF FILTERS FOR SEARCHING FOR DATA PRODUCTS
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_SITE_DATA_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      SITE_TEMPLATE  - A TEMPLATE FOR READING THE DIMITRI SITE FILE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      23 DEC 2010 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      23 DEC 2010 - C KENT   - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION AND CALLING SUCCESSFUL 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_SITE_DATA_TEMPLATE,VERBOSE=VERBOSE 

    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_SITE TEMPLATE: RETRIEVING TEMPLATE'
    
    TEMP_NAME     = ['SITE_id','TYPE','NLAT','SLAT','ELON','WLON']
    TEMP_TYPE     = [7,7,4,4,4,4]
    SITE_TEMPLATE = {VERSION        : 1.0                       , $
                     DATASTART      : 1 , $
                     DELIMITER      : ';' , $
                     MISSINGVALUE   : !values.f_NaN, $
                     COMMENTSYMBOL  : ''          , $
                     FIELDCOUNT     : N_ELEMENTS(TEMP_NAME), $
                     FIELDTYPES     : TEMP_TYPE, $
                     FIELDNAMES     : TEMP_NAME, $
                     FIELDLOCATIONS : INDGEN(N_ELEMENTS(TEMP_NAME)), $
                     FIELDGROUPS    : [INDGEN(N_ELEMENTS(TEMP_NAME))]}
    
   ; IF KEYWORD_SET(VERBOSE) THEN HELP,SITE_TEMPLATE       
    RETURN, SITE_TEMPLATE

END

