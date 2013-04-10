;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_ENDIAN_SIZE       
;* 
;* PURPOSE:
;*      COMPUTES THE ENDIAN SIZE OF THE MACHINE RUNNING IDL.
;* 
;* CALLING SEQUENCE:
;*      RES = GET_ENDIAN_SIZE      
;* 
;* INPUTS:
;*      NONE      
;*
;* KEYWORDS:
;*      VERBOSE - PROCESSING STATUS OUTPUTS     
;*
;* OUTPUTS:
;*      ENDIAN SIZE - 0 IS LITTLE ENDIAN, 1 IS BIG ENDIAN
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      20 NOV 2010 - C KENT    - DIMITRI-2 V1.0 ADAPTED FROM D FANNING (HTTP://WWW.DFANNING.COM/TIPS/ENDIAN_MACHINES.HTML)
;*      22 NOV 2010 - C KENT    - ADDED VERBOSE KEYWORD OPTION
;*      02 DEC 2010 - C KENT    - UPDATED HEADER
;*
;* VALIDATION HISTORY:
;*      01 DEC 2010 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION SUCCESSFUL,
;*                                ENDIAN_SIZE RETURNED NOMINAL
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_ENDIAN_SIZE,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GETTING MACHINE ENDIAN SIZE'
  ENDIAN_TEST = (BYTE(1, 0, 1))[0]
  IF (ENDIAN_TEST) THEN BEGIN
    ENDIAN_SIZE = 0 
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'MACHINE IS LITTLE ENDIAN'
  ENDIF ELSE BEGIN 
    ENDIAN_SIZE = 1
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'MACHINE IS BIG ENDIAN'
  ENDELSE

  RETURN, ENDIAN_SIZE

END