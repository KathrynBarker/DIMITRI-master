;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      DIMITRI_RSR_COLOURS       
;* 
;* PURPOSE:
;*      RETURNS THE DIMITRI SENSOR COLOURS FOR USE IN THE RSR PLOT WINDOW
;* 
;* CALLING SEQUENCE:
;*      RES = DIMITRI_RSR_COLOURS()      
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      RETURN  - A BYTE ARRAY OF SIZE [3,6] CONTAINING THE RGB INFORMATION FOR EACH SENSOR
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      28 JAN 2011 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      14 APR 2011 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION DIMITRI_RSR_COLOURS,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR COLOUR: RETRIEVING COLOUR DATA'

; DEFINE THE NUMBER OF DIMITRI SENSORS
  RSR_COL_SENSORS = 6

;NEEDS TO BE AN ARRAY OF [3XSENSORS]
  RSR_COLOURS = [                  $
                !COLOR.BLACK      ,$
                !COLOR.BLUE       ,$
                !COLOR.RED        ,$
                !COLOR.NAVY       ,$
                !COLOR.PURPLE     ,$
                !COLOR.GREEN  $
                ]   

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR COLOUR: REFORMING COLOUR DATA INTO CORRECT ARRAY SIZE'
  RSR_COLOURS = REFORM(RSR_COLOURS,3,RSR_COL_SENSORS)

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR COLOUR: RETURNING COLOUR DATA'
  RETURN,RSR_COLOURS

END
