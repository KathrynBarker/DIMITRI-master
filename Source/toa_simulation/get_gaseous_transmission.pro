;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_GASEOUS_TRANSMISSION 
;* 
;* PURPOSE:
;*      THIS FUNCTION EXTRACTS AND INTERPOLATES THE DIMITRI GASEOUS ABSORPTION AUX DATA 
;*      AT THE REQUESTED WAVELENGTHS
;*
;* CALLING SEQUENCE:
;*      RES = GET_GASEOUS_TRANSMISSION(WAVELENGTHS)
;* 
;* INPUTS:
;*      WAVELENGTHS - AN ARRAY OF THE REQUIRED WAVELENGTHS
;*
;* KEYWORDS:
;*      VERBOSE     - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TGAS        - THE EXTRACTED AND INTERPOLATED GASEOUS TRANSMISSION AT REQUESTED WAVELENGTHS
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

FUNCTION GET_GASEOUS_TRANSMISSION,WAVELENGTHS,VERBOSE=VERBOSE

;---------------------------
; GET AUX FILENAME

  TRANS_FILE = GET_DIMITRI_LOCATION('GAS_TRANS',VERBOSE=VERBOSE)

;---------------------------
; GET TEMPLATE

  RSR_TEMPLATE  = GET_DIMITRI_RSR_TEMPLATE(VERBOSE=VERBOSE)

;---------------------------
; READ AUX FILENAME

  DATA = READ_ASCII(TRANS_FILE,TEMPLATE=RSR_TEMPLATE)

;---------------------------
; EXTRACT TO WAVELENGTHS

  TGAS = EXTRACT_DIMITRI_RSR(DATA,WAVELENGTHS,VERBOSE=VERBOSE)
  RETURN,TGAS

END
