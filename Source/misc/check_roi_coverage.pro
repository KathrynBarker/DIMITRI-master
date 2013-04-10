;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      CHECK_ROI_COVERAGE       
;* 
;* PURPOSE:
;*      CHECKS IF THE PROVIDED ROI COORDINATES ARE WITHIN A GIVEN LAT/LON GRID
;* 
;* CALLING SEQUENCE:
;*      RES = CHECK_ROI_COVERAGE(CRC_LAT,CRC_LON,ICOORDS)      
;* 
;* INPUTS:
;*      CRC_LAT = A GRID OF LATITUDE POINTS IN DEGREES
;*      CRC_LON = A GRID OF LONGITUDE POINTS IN DEGREES
;*      ICOORDS = A 4 ELEMENT ARRAY OF THE NLAT, SLAT, ELON, WLON VALUES
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      ROICOVERED  = -1: ERROR, 0: NOT COMPLETELY COVERED, 1: COVERED
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      06 MAR 2012 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      06 MAR 2012 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION CHECK_ROI_COVERAGE,CR_LAT,CR_LON,CR_PIX,ICOORDS,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CHECK_ROI_COVERAGE: STARTING COVERAGE CHECK'
  CRCTOL  = 0.5 ; FIND PIXELS WITIN 0.5 DEGREES
  LATID   = [0,0,1,1]
  LONID   = [3,2,2,3]
  PSEL    = [1,-1,-1, 1] ; TL, TR, BR, BL
  
  CORNLATS = ICOORDS[LATID]
  CORNLONS = ICOORDS[LONID]

  LATtDIMS = SIZE(CR_LAT,/DIMENSIONS)
  LONtDIMS = SIZE(CR_LON,/DIMENSIONS)

;*************************************
; EXTRACT a square of the valid PIXELS
  
  TEMP = ARRAY_INDICES([LATTDIMS],CR_PIX,/DIMENSIONS)
  XMIN = MIN(TEMP[0,*])-2 > 0
  XMAX = MAX(TEMP[0,*])+2 < (LATTDIMS[0]-1)  
  YMIN = MIN(TEMP[1,*])-2 > 0
  YMAX = MAX(TEMP[1,*])+2 < (LATTDIMS[1]-1)   
  
  CRC_LAT = CR_LAT[XMIN:XMAX,YMIN:YMAX]
  CRC_LON = CR_LON[XMIN:XMAX,YMIN:YMAX]
  
  LATDIMS = SIZE(CRC_LAT,/DIMENSIONS)
  LONDIMS = SIZE(CRC_LON,/DIMENSIONS)

;*************************************  
; CHECK LAT AND LON EQUAL EACH OTHER
  
  IF NOT ARRAY_EQUAL(LATDIMS,LONDIMS) THEN BEGIN
    PRINT, 'CHECK_ROI_COVERAGE: ERROR, LAT AND LON NOT EQUAL SIZES'
    ROICOVERED = -1
    GOTO, NO_CRC
  END

;*************************************  
; FOR EACH CORNER PIXEL CHECK IF IT IS COVERED BY LAT LON

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CHECK_ROI_COVERAGE: STARTING LOOP ON CORNER COORDINATES'
  ROICOVERED = 0
  FOR CRCI = 0,N_ELEMENTS(ICOORDS)-1 DO BEGIN
  
   ; LOC = WHERE(ABS(CRC_LAT-CORNLATS[CRCI]) LT CRCTOL AND ABS(CRC_LON-CORNLONS[CRCI]) LT CRCTOL,CRCCOUNT)
    
   ; IF CRCCOUNT EQ 0 THEN BEGIN
   ;   ROICOVERED = 0
   ;   GOTO, NO_CRC
   ; ENDIF
    
   ; PDIST = GREAT_CIRCLE_DISTANCE(CORNLATS[CRCI],CORNLONS[CRCI],CRC_LAT[LOC],CRC_LON[LOC],/DEGREES)
    PDIST = GREAT_CIRCLE_DISTANCE(CORNLATS[CRCI],CORNLONS[CRCI],CRC_LAT,CRC_LON,/DEGREES)
    A   = MIN(PDIST)
    SS  = WHERE(ABS(PDIST-A) LT 0.000001)
    
    ;CRCINDXS = ARRAY_INDICES(LATDIMS,LOC[SS[0]],/DIMENSIONS)
    CRCINDXS = ARRAY_INDICES(LATDIMS,SS[0],/DIMENSIONS)
    NX = CRCINDXS[0]
    NY = CRCINDXS[1]
    NNX = NX+PSEL[CRCI] > 0 < (LATDIMS[0]-1)
  
    PDIST = GREAT_CIRCLE_DISTANCE(CRC_LAT[NX,NY],CRC_LON[NX,NY],CRC_LAT[NNX,NY],CRC_LON[NNX,NY],/DEGREES)
    
    IF A LT PDIST*1.125 THEN ROICOVERED = 1 ELSE BEGIN
     
      ROICOVERED = 0
      GOTO, NO_CRC
    ENDELSE
  
  ENDFOR

;************************************* 
; RETURN COVERAGE VALUE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CHECK_ROI_COVERAGE: COMPLETED ROI COVERAGE CHECK'  
  NO_CRC:
  
  RETURN,ROICOVERED

END