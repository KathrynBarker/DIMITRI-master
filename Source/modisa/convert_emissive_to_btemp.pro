;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      CONVERT_EMISSIVE_TO_BTEMP       
;* 
;* PURPOSE:
;*      CONVERTS THE MODISA EMISSIVE RADIANCE TO BRIGTHNESS TEMPERATURE USING PLANCK'S LAW
;* 
;* CALLING SEQUENCE:
;*      RES = CONVERT_EMISSIVE_TO_BTEMP(EMM_DATA,BAND_ID)      
;* 
;* INPUTS:
;*      EMM_DATA - A FLOAT OR DOUBLE ARRAY OF EMISSIVE RADIANCE DATA 
;*      BAND_ID  - THE BAND INDEX OF THE EMISSIVE RADIANCE DATA STARTING FROM 0
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      BTEMP    - AN ARRAY OF CONVERTED BRIGHTNESS TEMPERATURES IN KELVIN 
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      26 APR 2011 - C KENT   - DIMITRI-2 INITIAL VERSION
;*
;* VALIDATION HISTORY:
;*      14 DEC 2010 - C KENT    - 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION CONVERT_EMISSIVE_TO_BTEMP,EMM_DATA,BAND_ID,VERBOSE=VERBOSE

;-------------------------
; DEFINE PARAMETERS

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CONVERT_EMISSIVE_TO_BTEMP: STARTING CONVERSION'
  H = 6.62606896*10.^(-34.)
  C = 299792458.
  K = 1.3806504*10.^(-23.)
  LAMBDA = [3750.,3750.,3959.,4050.,4465.,4515.,6715.,7325.,8550.,9730.,11030.,12020.,13335.,13635.,13935.,14235.]
  RAD = EMM_DATA*10.^(6.)

;-------------------------
; CONVERT DATA USING THE PLANCK FUNCTION

  L     = LAMBDA[BAND_ID]*10.^(-9.)
  ALPHA = H*C
  BETA  = K*L
  DELTA = 2.*H*(C^(2.))*(L^(-5.))
  GAMMA = 1.+(DELTA/RAD)
  BTEMP = ALPHA/(BETA*ALOG(GAMMA))

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CONVERT_EMISSIVE_TO_BTEMP: MIN - ',MIN(BTEMP),' MAX - ',MAX(BTEMP)
  RETURN,BTEMP
  
END