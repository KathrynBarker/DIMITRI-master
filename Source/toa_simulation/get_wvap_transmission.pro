;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_WVAP_TRANSMISSION 
;* 
;* PURPOSE:
;*      THIS FUNCTION EXTRACTS AND INTERPOLATES THE DIMITRI WATER VAPOUR ABSORPTION AUX DATA 
;*      AT THE REQUESTED WAVELENGTHS
;*
;* CALLING SEQUENCE:
;*      RES = GET_WVAP_TRANSMISSION(WAVELENGTHS)
;* 
;* INPUTS:
;*      WAVELENGTHS - AN ARRAY OF THE REQUIRED WAVELENGTHS
;*
;* KEYWORDS:
;*      VERBOSE     - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      TWV         - THE EXTRACTED AND INTERPOLATED WVAP TRANSMISSION AT REQUESTED WAVELENGTHS
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

FUNCTION GET_WVAP_TRANSMISSION,WAVELENGTHS,VERBOSE=VERBOSE

;---------------------------
; GET AUX FILENAME

  TRANS_FILE = GET_DIMITRI_LOCATION('WVAP_TRANS',VERBOSE=VERBOSE)

;---------------------------
; GET TEMPLATE

  RSR_TEMPLATE  = GET_DIMITRI_RSR_TEMPLATE(VERBOSE=VERBOSE)

;---------------------------
; READ AUX FILENAME

  DATA = READ_ASCII(TRANS_FILE,TEMPLATE=RSR_TEMPLATE)

;---------------------------
; EXTRACT TO WAVELENGTHS

  Twv = EXTRACT_DIMITRI_RSR(DATA,WAVELENGTHS,VERBOSE=VERBOSE)
  RETURN,TWV

END
