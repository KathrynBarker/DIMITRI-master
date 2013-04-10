;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_CONFIGURATION_TEMPLATE 
;* 
;* PURPOSE:
;*      RETURNS THE TEMPLATE OF THE DIMITRI CONFIGURATION FILE.
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_CONFIGURATION_TEMPLATE()      
;* 
;* INPUTS:
;*      NONE 
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TEMPLATE - THE DIMITRI CONFIG FILE TEMPLATE 
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      22 MAR 2011 - C KENT    - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      14 APR 2011 - C KENT    - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                                COMPILATION AND OPERATION        
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_CONFIGURATION_TEMPLATE,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_TEMPLATE: RETRIEVING DATABASE TEMPLATE'
  NAME=['OPTION','VALUE']
  TYPE=[7,4]  
  TEMPLATE={       VERSION        : 1.0                       , $
                   DATASTART      : 1 , $
                   DELIMITER      : ';' , $
                   MISSINGVALUE   : !VALUES.F_NAN, $
                   COMMENTSYMBOL  : ''          , $
                   FIELDCOUNT     : N_ELEMENTS(NAME), $
                   FIELDTYPES     : TYPE, $
                   FIELDNAMES     : NAME, $
                   FIELDLOCATIONS : INDGEN(N_ELEMENTS(NAME)), $
                   FIELDGROUPS    : [INDGEN(N_ELEMENTS(NAME))]}      
  
  RETURN, TEMPLATE

END
