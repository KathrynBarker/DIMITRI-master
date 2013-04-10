;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_OZONE_TRANSMISSION 
;* 
;* PURPOSE:
;*      THIS FUNCTION EXTRACTS AND INTERPOLATES THE DIMITRI OZONE ABSORPTION AUX DATA 
;*      AT THE REQUESTED WAVELENGTHS
;*
;* CALLING SEQUENCE:
;*      RES = GET_OZONE_TRANSMISSION(WAVELENGTHS)
;* 
;* INPUTS:
;*      WAVELENGTHS - AN ARRAY OF THE REQUIRED WAVELENGTHS
;*
;* KEYWORDS:
;*      VERBOSE     - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TO3         - THE EXTRACTED AND INTERPOLATED OZONE TRANSMISSION AT REQUESTED WAVELENGTHS
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      20 APR 2011 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_OZONE_TRANSMISSION,WAVELENGTHS,VERBOSE=VERBOSE

;---------------------------
; GET AUX FILENAME

  TRANS_FILE = GET_DIMITRI_LOCATION('OZONE_TRANS',VERBOSE=VERBOSE)

;---------------------------
; GET TEMPLATE

  RSR_TEMPLATE  = GET_DIMITRI_RSR_TEMPLATE(VERBOSE=VERBOSE)

;---------------------------
; READ AUX FILENAME

  DATA = READ_ASCII(TRANS_FILE,TEMPLATE=RSR_TEMPLATE)

;---------------------------
; EXTRACT TO WAVELENGTHS

  TO3 = EXTRACT_DIMITRI_RSR(DATA,WAVELENGTHS,VERBOSE=VERBOSE)
  RETURN,TO3

END


