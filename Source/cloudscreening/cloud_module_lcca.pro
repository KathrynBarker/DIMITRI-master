;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      CLOUD_MODULE_LCCA       
;* 
;* PURPOSE:
;*      THIS FUNCTION PERFORMS THE LANDSAT 7 AUTOMATED CLOUD CLEARING ALGORITHIM (LCCA). 
;*      IT UTILISES THERMAL DATA AND PERFORMS 2 PASSESS. THE FIRST PASS INCLUDES 8 FILTERS 
;*      TO MAKE INITIAL ESTIMATIONS ON PIXELS, THE SECOND PASS USES A CLOUD POPULATION 
;*      ESTIMATED FROM PASS 1 TO CLASSIFY ALL AMBIGUOUS DATA POINTS.
;* 
;* CALLING SEQUENCE:
;*      RES = CLOUD_MODULE_LCCA(LCCA_REF)    
;* 
;* INPUTS:
;*      LCCA_REF   - A FLOAT ARRAY CONTAINING THE TOA REFLECTANCE AT 555NM,660NM,870NM,
;*                   1.6MICRON AND 11 MICRON WAVELENGTHS [NB_PIXELS,REF_BANDS].
;*                   THE 11 MICRON BAND SHOULD BE IN TOA TEMPERATURE (KELVIN).
;*
;* KEYWORDS:
;*      VERBOSE    - PROCESSING STATUS OUTPUTS
;*      MODISA     - UTILISES COEFICIENTS INTENDED FOR USE WITH MODISA DATA
;*
;* OUTPUTS:
;*      PIXEL_CLASSIFICATION - AN INTEGER ARRAY OF NUM_PIXELS, 0 MEANS CLEAR PIXEL, 
;*                              1 MEANS CLOUDY
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      06 APR 2011 - C KENT   - DIMITRI-2 V1.0
;*      07 APR 2011 - C KENT   - ADDED BAND INDEX VALUES
;*      16 MAY 2011 - C KENT   - ADDEDD MODIS KEYWORD, SMALL BUG FIXES
;*
;* VALIDATION HISTORY:
;*      12 APR 2011 - C KENT   - NOMINAL COMPILATION AND OPERATION ON WINDOWS 32BIT 
;*                               IDL 7.1 AND LINUX 64BIT IDL 8.0
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION CLOUD_MODULE_LCCA,LCCA_REF,VERBOSE=VERBOSE,MODISA=MODISA

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: STARTING LCCA CLOUD SCREENING'

;----------------------------
; DEFINE BAND INDEXES

  B2 = 0
  B3 = 1
  B4 = 2
  B5 = 3
  B6 = 4

;----------------------------
; DEFINE IDENTIFIERS AND NB OF PIXELS

  NB_PIXELS     = N_ELEMENTS(LCCA_REF[*,0])
  NOSELECT_ID   = 0
  CLEAR_ID      = 1
  SNOW_ID       = 2
  AMBI_ID       = 3
  COLD_CLOUD_ID = 4
  WARM_CLOUD_ID = 5
  CLOUD_ID      = 6
  RAISE_ID      = 10

  PX_CLEAR = 0
  PX_CLOUD = 1

;----------------------------
; DEFINE ARRAY TO HOLD PIXEL CLASSIFICATION

  PIXEL_CLASSIFICATION = INTARR(NB_PIXELS)
  ;CLOUD_POP_ID = INTARR[NUM_PIXELS]
  P2CLOUDTYPE = INTARR(NB_PIXELS)

;----------------------------
; DEFINE THRESHOLDS

  P1F1_THRESHOLD = 0.08
  P1F2_THRESHOLD = 0.7
  P1F3_THRESHOLD = 300.0
  P1F4_THRESHOLD = 225.0
  P1F5_THRESHOLD = 2.0
  P1F6_THRESHOLD = 2.0
  P1F7_THRESHOLD = 1.0
  P1F8_THRESHOLD = 210.0

  IF KEYWORD_SET(MODISA) THEN BEGIN
    P1F4_THRESHOLD = 250.
    P1F7_THRESHOLD = 0.8
    P1F8_THRESHOLD = 235.
  ENDIF

  SNOW_THRESHOLD = 0.01
  DEST_THRESHOLD = 0.5
  COLD_THRESH    = 0.4
  CLOUD_TEMP_THRESH = 295.0

  P2_UPTILE =   0.975 
  P2_LPTILE =   0.835
  P2_MPTILE =   0.9875
 
;----------------------------
; COMPUTE B5/B6 COMPOSITE AND NDSI
  
  B5_B6_COMP  = (1-LCCA_REF[*,B5])*LCCA_REF[*,B6]
  NDSI        = (LCCA_REF[*,B2]-LCCA_REF[*,B5])/(LCCA_REF[*,B2]+LCCA_REF[*,B5])

;----------------------------
; PASS1, FILTER 1: BRIGHTNESS THRESHOLD - BAND 3 COMPARED TO 0.8

  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND LCCA_REF[*,B3] LT P1F1_THRESHOLD,P1F1_COUNT)
  IF P1F1_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = CLEAR_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F1 NUMBER = ',P1F1_COUNT

;----------------------------
; PASS1, FILTER 2: SNOW DIFFERENCE - B2-B5/B2+B5  AGAINST0.3
  
  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND NDSI GT P1F2_THRESHOLD,P1F2_COUNT)
  IF P1F2_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = SNOW_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F2 NUMBER = ',P1F2_COUNT

;----------------------------
; PASS1, FILTER 3: TEMP THRSHOLD - B6 VERSUS 300K
  
  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND LCCA_REF[*,B6] GT P1F3_THRESHOLD,P1F3_COUNT)
  IF P1F3_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = CLEAR_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F3 NUMBER = ',P1F3_COUNT

;----------------------------
; PASS1, FILTER 4: B5/6 COMP - (1-B5)*B6 COMPARED TO 225

  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND B5_B6_COMP GT P1F4_THRESHOLD,P1F4_COUNT)
  IF P1F4_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = AMBI_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F4 NUMBER = ',P1F4_COUNT

;----------------------------
; PASS1, FILTER 5: B4/3 RATIO - B4/B3 COMPARED TO 2.0
  
  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND (LCCA_REF[*,B4]/LCCA_REF[*,B3]) GT P1F5_THRESHOLD,P1F5_COUNT)
  IF P1F5_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = AMBI_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F5 NUMBER = ',P1F5_COUNT

;----------------------------
; PASS1, FILTER 6: B4/2 RATIO - B4/B2 COMAPRED TO 2.0
  
  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND (LCCA_REF[*,B4]/LCCA_REF[*,B2]) GT P1F6_THRESHOLD,P1F6_COUNT)
  IF P1F6_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = AMBI_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F6 NUMBER = ',P1F6_COUNT

;----------------------------
; PASS1, FILTER 7: B4/5 RATIO - B4/B5 COMAPRED TO 1.0
  
  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND (LCCA_REF[*,B4]/LCCA_REF[*,B5]) LT P1F7_THRESHOLD,P1F7_COUNT)
  IF P1F7_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = AMBI_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F7 NUMBER = ',P1F7_COUNT

;----------------------------
; PASS1, FILTER 8: B5/6 COMP - (1-B5)*B6 COMPARED TO 210
  
  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND B5_B6_COMP GT P1F8_THRESHOLD,P1F8_COUNT)
  IF P1F8_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = WARM_CLOUD_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F8 WARM NUMBER = ',P1F8_COUNT

  IDX = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID AND B5_B6_COMP LT P1F8_THRESHOLD,P1F8_COUNT)
  IF P1F8_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = COLD_CLOUD_ID
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: P1_F8 COLD NUMBER = ',P1F8_COUNT

;----------------------------
; CHECK ALL PIXELS ARE NOW CLASSIFIED

  RES = WHERE(PIXEL_CLASSIFICATION EQ NOSELECT_ID, COUNT)
    IF COUNT GT 0 THEN BEGIN
    PRINT,'CLOUD_MODULE_LCCA: ERROR, SOME PIXELS NOT CLASSIFIED!!!', ' NUM PIX = ',COUNT
    RETURN,[-1.0]
  ENDIF

;--------------------------------
; COMPUTE SNOW AND DESERT PERCENTAGE

  SNOW_PCENT = FLOAT(P1F2_COUNT)/FLOAT(NB_PIXELS)
  DEST_PCENT = FLOAT(P1F7_COUNT)/FLOAT(NB_PIXELS)
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SNOW PERCENTAGE = ',SNOW_PCENT,' DESERT PERCENTAGE = ',DEST_PCENT

;--------------------------------
; IF IMAGE IS SNOWY THEN SET CLOUD POPULATION 
; AS ONLY COLD CLOUD AND WARM CLOUDS AS 
; AMBIGUOUS, ELSE USE BOTH WARM AND COLD CLOUDS

  IF SNOW_PCENT GT SNOW_THRESHOLD THEN BEGIN
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SNOWY SCENE, SETTING CLOUD POPULATION AS COLD CLOUD'
    SNOW_SCENE = 1
    IDX = WHERE(PIXEL_CLASSIFICATION EQ COLD_CLOUD_ID,CLOUD_POP_COUNT)
    IF CLOUD_POP_COUNT GT 0 THEN CLOUD_POP_ID = IDX
    IDX = WHERE(PIXEL_CLASSIFICATION EQ WARM_CLOUD_ID,COUNT_WARM)
    IF COUNT_WARM GT 0 THEN PIXEL_CLASSIFICATION[IDX] = AMBI_ID
  ENDIF ELSE BEGIN
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: NON SNOWY SCENE, SETTING CLOUD POPULATION AS COLD AND WARM CLOUD'
   SNOW_SCENE = 0
    IDX = WHERE(PIXEL_CLASSIFICATION EQ COLD_CLOUD_ID OR PIXEL_CLASSIFICATION EQ WARM_CLOUD_ID ,CLOUD_POP_COUNT)
    IF CLOUD_POP_COUNT GT 0 THEN CLOUD_POP_ID = IDX
  ENDELSE
  IF CLOUD_POP_COUNT EQ 0 THEN GOTO,SKIP_PASS_2

;--------------------------------
; CHECK IF SCENE IS DESERT

  IF DEST_PCENT LE DEST_THRESHOLD THEN DESERT_SCENE = 1 ELSE DESERT_SCENE=0

;--------------------------------
; GET COLD CLOUD PERCENTAGE AND STATISTICS OF CLOUD POPULATION

  IDX = WHERE(PIXEL_CLASSIFICATION EQ COLD_CLOUD_ID,COLD_COUNT)
  COLD_PCENT =  FLOAT(COLD_COUNT)/FLOAT(NB_PIXELS)

  CLOUD_POP_MIN = MIN(LCCA_REF[CLOUD_POP_ID,B6])
  CLOUD_POP_MAX = MAX(LCCA_REF[CLOUD_POP_ID,B6])
  CLOUD_POP_AVG = MEAN(LCCA_REF[CLOUD_POP_ID,B6]) 
  IF N_ELEMENTS(LCCA_REF[CLOUD_POP_ID,B6]) GT 1 THEN BEGIN
    CLOUD_POP_STD = STDEV(LCCA_REF[CLOUD_POP_ID,B6])
    CLOUD_POP_SKW = SKEWNESS(LCCA_REF[CLOUD_POP_ID,B6])
  ENDIF ELSE BEGIN
    CLOUD_POP_STD = 0.
    CLOUD_POP_SKW = 0.  
  ENDELSE
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: CLOUD POPULATION STATISTICS - '
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: MIN - ',CLOUD_POP_MIN,' MAX - ',CLOUD_POP_MAX
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: MEAN - ',CLOUD_POP_AVG,' STD - ',CLOUD_POP_STD
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SKEW - ',CLOUD_POP_SKW
  IF CLOUD_POP_MIN eq CLOUD_POP_MAX THEN GOTO,SKIP_PASS_2

;--------------------------------
; DETERMINE WHETHER TO ENGAGE PASS 2 OR NOT

  IF  DESERT_SCENE EQ 0 OR               $
      COLD_PCENT LT COLD_THRESH OR       $
      CLOUD_POP_AVG GT CLOUD_TEMP_THRESH THEN BEGIN

;--------------------------------
; SET ALL COLD CLOUDS AS CLOUD AND EVERYTHING 
; ELSE AS CLEAR, OR ELSE SET ALL PIXELS AS CLEAR

    IF DESERT_SCENE EQ 1 AND CLOUD_POP_AVG LT CLOUD_TEMP_THRESH THEN BEGIN 
      IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SETTING ALL COLD PIXELS AS CLOUD, EVERYTHING ELSE IS CLEAR'
      IDX = WHERE(PIXEL_CLASSIFICATION NE COLD_CLOUD_ID,CLOUD_POP_COUNT)
      IF CLOUD_POP_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = CLEAR_ID
      IDX = WHERE(PIXEL_CLASSIFICATION GT CLEAR_ID,CLOUD_POP_COUNT)
      IF CLOUD_POP_COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = CLOUD_ID
    ENDIF ELSE BEGIN 
      IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SCENE HAS NO CLOUD
      PIXEL_CLASSIFICATION[*] = CLEAR_ID
    ENDELSE
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SKIPPING PASS 2'
    GOTO,SKIP_PASS_2
  ENDIF ELSE begin
  CLOUD_POP = LCCA_REF[CLOUD_POP_ID,B6]
  PIXEL_CLASSIFICATION[CLOUD_POP_ID] = CLOUD_ID
  endelse

;--------------------------------
; RETRIEVE THE NEW CLOUD POPULATION THRESHOLDS

  CLOUD_POP = CLOUD_POP[sort(CLOUD_POP)]
  IF N_ELEMENTS(CLOUD_POP) LT 5  OR MAX(CLOUD_POP LE 0.) THEN GOTO,SKIP_PASS_2
  
  CLOUD_HIST  = HISTOGRAM(CLOUD_POP,NBINS=500,LOCATIONS=CLOUD_LOC)
  CTOT        = TOTAL(CLOUD_HIST, /CUMULATIVE) 
  TOT         = TOTAL(FLOAT(CLOUD_HIST)) 
  PARRAY      = CTOT/TOT
  IF N_ELEMENTS(PARRAY) EQ 1 THEN GOTO,SKIP_PASS_2

  P2_UTHRESH = cloud_loc[VALUE_LOCATE(PARRAY, P2_UPTILE)] 
  P2_LTHRESH = cloud_loc[VALUE_LOCATE(PARRAY, P2_LPTILE)] 
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: CLOUD POPULATION PERCENTILES - ',P2_LTHRESH,P2_UTHRESH

;--------------------------------
; MODIFY LIMITS IF POSITIVE SKEW FOUND

  IF CLOUD_POP_SKW GT 0.0 THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: POSITIVE SKEW, MODIFYING LIMITS'
    SF = (CLOUD_POP_SKW<1.0)*CLOUD_POP_STD
    P2_UTHRESH = SF*P2_UTHRESH
    P2_LTHRESH = SF*P2_LTHRESH
    P2_MTHRESH = CLOUD_LOC[VALUE_LOCATE(PARRAY, P2_MPTILE)] 
    IF P2_UTHRESH GT P2_MTHRESH THEN BEGIN
      NSF = P2_MTHRESH/(P2_UTHRESH/SF)
      P2_LTHRESH = NSF*P2_LTHRESH
      P2_UTHRESH = P2_MTHRESH
    ENDIF
  ENDIF

;--------------------------------
; FIND AMBIGUOUS PIXELS

  ABI_IDX = WHERE(PIXEL_CLASSIFICATION EQ AMBI_ID,AMBI_COUNT)
  IF AMBI_COUNT EQ 0 THEN GOTO, SKIP_PASS_2

;--------------------------------
; IF AMBI PIXELS ARE BETWEEN THRESHOLDS 
; THEN SET AS CLOUD TYPE 1, ELSE SET THEM AS TYPE 2

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: DEFINING TWO NEW TYPES OF CLOUD FOR AMBIGUOUS PIXELS
  P2_T1 = WHERE(LCCA_REF[ABI_IDX,B6] LT P2_UTHRESH AND LCCA_REF[ABI_IDX,B6] GT P2_LTHRESH,TEMP_COUNT)
  IF TEMP_COUNT GT 0 THEN BEGIN
    P2CLOUDTYPE[ABI_IDX[P2_T1]]=1
    C1_TYPE_PCENT = FLOAT(N_ELEMENTS(P2_T1))/FLOAT(NB_PIXELS)
    C1_TYPE_MEAN = MEAN(LCCA_REF[ABI_IDX[P2_T1],B6])
    c1_valid = 1
  ENDIF ELSE BEGIN
    C1_TYPE_PCENT = 0.0
    C1_TYPE_MEAN = 0.0
    c1_valid = 0 
  ENDELSE

  P2_T2 = WHERE(LCCA_REF[ABI_IDX,B6] LT P2_LTHRESH,TEMP_COUNT)
  IF TEMP_COUNT GT 0 THEN BEGIN 
    P2CLOUDTYPE[ABI_IDX[P2_T2]]=2
    C2_TYPE_PCENT = FLOAT(N_ELEMENTS(P2_T2))/FLOAT(NB_PIXELS)
    C2_TYPE_MEAN = MEAN(LCCA_REF[ABI_IDX[P2_T2],B6])
    C2_VALID = 1
  ENDIF ELSE BEGIN
    C2_TYPE_PCENT = 0.0
    C2_TYPE_MEAN = 0.0 
    C2_VALID = 0
  ENDELSE

;--------------------------------
; IF TYPE 1 PERCENTAGE IS LOW AND MEAN TEMPERATURE 
; IS LOW AND IT ISN'T A SNOW SCENE THEN SET 
; ALL AMBIGUOUS PIXELS AS CLOUD
; IF TYPE 2 PERCENTAGE IS LOW AND MEAN TEMPERATURE 
; IS LOW BUT IT ISN'T SNOW THEN SET ONLY 
; C2 PIXELS AS CLOUD

  IF C1_TYPE_PCENT LT COLD_THRESH AND C1_TYPE_MEAN LT CLOUD_TEMP_THRESH AND SNOW_SCENE EQ 0 and c1_valid eq 1 THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SETTING ALL AMBIGUOUS PIXELS AS CLOUD'
    PIXEL_CLASSIFICATION[ABI_IDX[P2_T1]] = CLOUD_ID 
    IF P2_T2[0] GT -1 THEN PIXEL_CLASSIFICATION[ABI_IDX[P2_T2]] = CLOUD_ID
  ENDIF ELSE BEGIN
    IF C2_TYPE_PCENT LT COLD_THRESH AND C2_TYPE_MEAN LT CLOUD_TEMP_THRESH and c2_valid eq 1 THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SETTING ONLY C2 AMBIGUOUS PIXELS AS CLOUD'
      IDX = WHERE(P2CLOUDTYPE EQ 2, COUNT)
      IF COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = CLOUD_ID ; SET ONLY C2 CLOUDS AS CLOUD (AMBI PIXELS WILL BE CHANGED NEXT)
    ENDIF
  ENDELSE

;--------------------------------
; SET EVERYTHING THATS NOT CLOUD AS 
; CLEAR, AND CLOUD AS CLOUD

  SKIP_PASS_2:

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'CLOUD_MODULE_LCCA: SETTING CLOUD AS CLOUD AND EVERYTHING ELSE AS CLEAR'
  IDX = WHERE(PIXEL_CLASSIFICATION NE CLOUD_ID,COUNT)
  IF COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = PX_CLEAR

  IDX = WHERE(PIXEL_CLASSIFICATION EQ CLOUD_ID,COUNT)
  IF COUNT GT 0 THEN PIXEL_CLASSIFICATION[IDX] = PX_CLOUD

  RETURN,PIXEL_CLASSIFICATION

END