;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      COMPUTE_PARASOL_VIEWING_GEOMETRIES       
;* 
;* PURPOSE:
;*      COMPUTES THE VZA AND RAA FOR PARASOL PRODUCTS
;* 
;* CALLING SEQUENCE:
;*      RES = COMPUTE_PARASOL_VIEWING_GEOMETRIES(PVZA,PRAA,PDVZC,PDVZS)     
;* 
;* INPUTS:
;*      PVZA  - THE VZA IN DEGREES FOR 670NM
;*      PRAA  - THE RAA IN DEGREES FOR 670NM
;*      PDVZC - THE DELTA COSINE ANGLE FOR PARASOL PIXEL
;*      PDVZS - THE DELTA SINE ANGLE FOR PARASOL PIXEL     
;*
;* KEYWORDS:
;*      ORDER - RETURNS THE ANGLES IN ACSENDING WAVELENGTH ORDER
;*
;* OUTPUTS:
;*      .VZA  - THE COMPUTED ZENITH GEOMETRIES
;*      .RAA  - THE COMPUTED AZIMUTH GEOMETRIES
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      16 DEC 2011 - C KENT  - INITIAL DIMITRI VERSION
;*
;* VALIDATION HISTORY:
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION COMPUTE_PARASOL_VIEWING_GEOMETRIES,PVZA,PRAA,PDVZC,PDVZS,ORDER=ORDER

;------------------------------
; USE ORDER KEYWORD TO PUT THE 
; NEW ANGLES IN ASCENDING WAVELENGTH ORDER

  XJ = [-6.,-4.,-3.,-2.,0.,2.,3.,4.,6.]

;------------------------------
; CONVERT DEGREES TO RADIANS

  RVZA = !DTOR*PVZA
  RRAA = !DTOR*PRAA
  RDVZC= !DTOR*PDVZC
  RDVZS= !DTOR*PDVZS

  VAR1 = (RVZA*COS(RRAA))+(XJ*RDVZC)
  VAR2 = (RVZA*SIN(RRAA))+(XJ*RDVZS)

  NVZA = SQRT((VAR1^2)+(VAR2^2))
  NRAA = ATAN(VAR2/VAR1)

;------------------------------
; CONVERT BACK TO DEGREES

  NVZA = !RADEG*NVZA
  NRAA = !RADEG*NRAA

  TEMP = WHERE(VAR1 LT 0.0,COUNT)
  IF COUNT GT 0 THEN NRAA[TEMP] = NRAA[TEMP]+180.

  IF KEYWORD_SET(ORDER) THEN BEGIN
  TEMP = [1,0,3,4,5,6,8,7,2]
  NVZA = NVZA[TEMP]
  NRAA = NRAA[TEMP]
  ENDIF

;------------------------------
; RETURN THE ANGLE DATA

  RETURN,{VZA:NVZA,RAA:NRAA}

END