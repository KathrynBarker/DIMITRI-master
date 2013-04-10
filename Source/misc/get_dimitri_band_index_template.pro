;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_BAND_INDEX_TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS THE TEMPLATE REQUIRED FOR READING THE BAND INDEX DIMITRI FILE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_BAND_INDEX_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      SITE_TEMPLATE  - A TEMPLATE FOR READING THE DIMITRI BAND INDEX FILE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      19 JAN 2011 - C KENT   - DIMITRI-2 V1.0
;*      05 JUL 2011 - C KENT   - ADDED MODISA_O AND MODISA_L SENSOR CONFIGURATIONS
;*
;* VALIDATION HISTORY:
;*      19 DEC 2010 - C KENT   - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION AND CALLING SUCCESSFUL 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_BAND_INDEX_TEMPLATE,VERBOSE=VERBOSE

    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI BAND ID TEMPLATE: RETRIEVING TEMPLATE'
    
    TEMP_NAME      = ['DIMITRI_ID','WAVE_CENTRE','AATSR','ATSR2','MERIS','MODISA_O','MODISA_L','PARASOL','VEGETATION']
    TEMP_TYPE      = [3,4,3,3,3,3,3,3,3]
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