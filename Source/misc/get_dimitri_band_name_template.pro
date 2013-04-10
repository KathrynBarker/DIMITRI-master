;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_BAND_NAME_TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS THE TEMPLATE REQUIRED FOR READING THE BAND NAME DIMITRI FILE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_BAND_NAME_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      INDEX_TEMPLATE  - A TEMPLATE FOR READING THE DIMITRI BAND INDEX FILE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      19 SEP 2011 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*       
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_BAND_NAME_TEMPLATE,VERBOSE=VERBOSE

    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI BAND NAME TEMPLATE: RETRIEVING TEMPLATE'
    
    TEMP_NAME      = ['ID','AATSR','ATSR2','MERIS','MODISA','PARASOL','VEGETATION']
    TEMP_TYPE      = [3,3,3,3,3,3,3]
    INDEX_TEMPLATE = {VERSION       : 1.0                       , $
                     DATASTART      : 1 , $
                     DELIMITER      : ';' , $
                     MISSINGVALUE   : !VALUES.F_NAN, $
                     COMMENTSYMBOL  : ''          , $
                     FIELDCOUNT     : N_ELEMENTS(TEMP_NAME), $
                     FIELDTYPES     : TEMP_TYPE, $
                     FIELDNAMES     : TEMP_NAME, $
                     FIELDLOCATIONS : INDGEN(N_ELEMENTS(TEMP_NAME)), $
                     FIELDGROUPS    : [INDGEN(N_ELEMENTS(TEMP_NAME))]}
    
    ;IF KEYWORD_SET(VERBOSE) THEN HELP,INDEX_TEMPLATE       
    RETURN, INDEX_TEMPLATE

END