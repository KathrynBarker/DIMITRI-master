;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_CONFIGURATION 
;* 
;* PURPOSE:
;*      RETURNS THE DIMITRI CONFIGURATION DATA.
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_CONFIGURATION()      
;* 
;* INPUTS:
;*      NONE 
;*
;* KEYWORDS:
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      CFIG_DATA - THE DIMITRI CONFIGURATION DATA 
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

FUNCTION GET_DIMITRI_CONFIGURATION,VERBOSE=VERBOSE

;---------------------
; GET CONFIG FILENAME

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_CONFIG: RETRIEVING CFIG FILE LOCATION'
  CFIG_FILE = GET_DIMITRI_LOCATION('CONFIG')

;---------------------
; GET CONF TEMPLATE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_CONFIG: RETRIEVING CFIG TEMPLATE'
  CFIG_TEMPLATE = GET_DIMITRI_CONFIGURATION_TEMPLATE()

;---------------------
; READ ASCII THE CFIG FILE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_CONFIG: READING CONFIGURATION'
  CFIG_DATA = READ_ASCII(CFIG_FILE,TEMPLATE=CFIG_TEMPLATE)

;---------------------
; RETURN THE STRUCTURE

  RETURN,CFIG_DATA

END