;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_SENSOR_DATA_TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS AN ARRAY OF FILTERS FOR SEARCHING FOR DATA PRODUCTS
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_SENSOR_DATA_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      SITE_TEMPLATE  - A TEMPLATE FOR READING THE DIMITRI SENSOR FILE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      13 JAN 2011 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      13 DEC 2010 - C KENT   - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION AND CALLING SUCCESSFUL 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_SENSOR_DATA_TEMPLATE,VERBOSE=VERBOSE 

    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_SENSOR TEMPLATE: RETRIEVING TEMPLATE'
    
    TEMP_NAME     = ['SENSOR_ID','PIX_RES','NUM_BANDS','NUM_DIR']
    TEMP_TYPE     = [7,4,3,3]
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
    
 ;   IF KEYWORD_SET(VERBOSE) THEN HELP,SITE_TEMPLATE       
    RETURN, SITE_TEMPLATE

END

