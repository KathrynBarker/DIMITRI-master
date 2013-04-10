;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      ROUJEAN_BRDF_COEF       
;* 
;* PURPOSE:
;*      RETURNS THE ROUJEAN COEFICIENTS FOR GIVEN GEOMETRIES AND RHO
;* 
;* CALLING SEQUENCE:
;*      RES = ROUJEAN_BRDF_COEF(BC_SZA,BC_VZA,BC_DPHI,BC_RHO)     
;* 
;* INPUTS:
;*      BC_SZA       - A SCALAR OR ARRAY OF SOLAR ZENITH VALUES IN RADIANS FOR COMPUTATION
;*      BC_VZA       - A SCALAR OR ARRAY OF VIEWING ZENITH VALUES IN RADIANS FOR COMPUTATION
;*      BC_DPHI      - A SCALAR OR ARRAY OF RELATIVE AZIMUTH VALUES IN RADIANS FOR COMPUTATION
;*      BC_RHO       - A SCALAR OR ARRAY OF RHO VALUES FOR COMPUTATION
;*
;* KEYWORDS:
;*      DEGREES      - SET TO INDICATE INPUT ANGLES ARE DEGREES AND NOT RADIANS AS EXPECTED      
;*      VERBOSE      - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      K_COEFF      - A 3-ELEMENT ARRAY OF THE ROUJEAN BRDFY COEFICIENTS
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      22 MAR 2007 - M BOUVET - PROTOTYPE DIMITRI VERSION
;*      24 JAN 2011 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      15 APR 2011 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION. TESTED ON MERIS 2ND REPROCESSING 
;*                               WITH MERIS 3RD REPROCESSING AND MODISA COLLECTION 5 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION ROUJEAN_BRDF_COEF,BC_SZA,BC_VZA,BC_DPHI,BC_RHO,DEGREES=DEGREES,VERBOSE=VERBOSE	

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'ROUJEAN_BRDF_COEF: STARTING RHO COMPUTATION'

;-----------------------------------------
; GET THE NUMBER OF OBSERVATIONS
  
  N_OBS=N_ELEMENTS(BC_RHO)

;-----------------------------------------
; COMPUTE THE [F] MATRIX
  
  F_MATRIX=FLTARR(3, N_OBS)
  F_MATRIX[0,*]=1.
  ;IF KEYWORD_SET(DEGREES) THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'ROUJEAN_BRDF_COEF: DEGREES KEYWORD SET'
    F_MATRIX[1,*] = ROUJEAN_BRDF_KERNEL_F1(BC_SZA,BC_VZA,BC_DPHI,DEGREES=DEGREES)
    F_MATRIX[2,*] = ROUJEAN_BRDF_KERNEL_F2(BC_SZA,BC_VZA,BC_DPHI,DEGREES=DEGREES)
  ;ENDIF ELSE BEGIN
  ;  F_MATRIX[1,*] = ROUJEAN_BRDF_KERNEL_F1(BC_SZA,BC_VZA,BC_DPHI)
  ;  F_MATRIX[2,*] = ROUJEAN_BRDF_KERNEL_F2(BC_SZA,BC_VZA,BC_DPHI)
  ;ENDELSE

  T_F_MATRIX  = TRANSPOSE(F_MATRIX)
  K_COEFF     = T_F_MATRIX##F_MATRIX
  K_COEFF     = INVERT(K_COEFF)
  K_COEFF     = K_COEFF##T_F_MATRIX
  K_COEFF     = K_COEFF##TRANSPOSE(BC_RHO)

;-----------------------------------------
; RETURNING THE K COEFICIENTS
  
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'ROUJEAN_BRDF_COEF: RETURNING K-COEFICIENTS'  
  RETURN, K_COEFF

END