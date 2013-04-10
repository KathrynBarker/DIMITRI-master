;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      DIMITRI_VISUALISATION_REFLECTANCE     
;* 
;* PURPOSE:
;*      THIS PROGRAM AUTOMATICALLY SERACHES AND RETRIEVES THE DOUBLET REFLECTANCE 
;*      INFORMATION OUTPUT BY DIMITRI GIVEN AN OUTPUT FOLDER AND REFERENCE 
;*      SENSOR CONFIGURATION.
;* 
;* CALLING SEQUENCE:
;*      RES = DIMITRI_VISUALISATION_REFLECTANCE(ED_FOLDER,VR_REGION,DIMITRI_BAND,REF_SENSOR,$
;*                                              REF_PROC_VER,VERBOSE=VERBOSE)    
;*
;* INPUTS:
;*      ED_FOLDER     - A STRING OF THE FULL PATH FOR THE DOUBLET_EXTRACTION OUTPUT FOLDER
;*      VR_REGION     - A STRING OF THE DIMITRI VALIDATION SITE REQUESTED
;*      DIMITRI_BAND  - THE REQUIRED DIMITRI BAND INDEX (STARTS FROM 0)
;*      REF_SENSOR    - A STRING OF THE REFERENCE SENSOR UTILISED FOR PROCESSING
;*      REF_PROC_VER  - A STRING OF THE REFERENCE SENSOR'S PROCESSING VERSION 
;*
;* KEYWORDS:
;*      VERBOSE - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      A STRUCTURE WITH THE FOLLOWING TAGS:
;*      ERROR                 - THE ERROR STATUS CODE, 0 = NOMINAL, 1 OR -1 = ERROR
;*      DATA                  - AN ARRAY CONTAINING ALL DOUBLET REFLECTANCE
;*      NUM_SENS_CONFIGS      - NUMBER OF SENSOR CONFIGURATIONS FOUND
;*      SENSOR_CONFIGS        - A STRING OF THE SENSOR CONFIGURATIONS FOUND
;*      NUM_XELEMENTS         - TOTAL NUMBER OF X VALUES (DATES) RETIREVED
;*      SENS_CONFIG_ABLE      - AN INTEGER ARRAY DESCRIBING IF DATA IS AVAILABLE FOR A
;*                              CERTAIN SENSOR CONFIGURATION
;*      SENS_CONFIG_ABLE_CHI  - AN INTEGER ARRAY DESCRIBING IF CHI DATA IS AVAILABLE FOR A
;*                              CERTAIN SENSOR CONFIGURATION
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      08 FEB 2011 - C KENT    - DIMITRI-2 V1.0
;*      08 MAR 2011 - C KENT    - ADDED DIALOG MESSAGE AND EXIT IF NO REFERENCE DATA FOUND
;*      04 JUL 2011 - C KENT    - ADDED AUX INFO TO INTERNAL SAV FILE
;*      25 JUL 2011 - C KENT    - MINOR BUG FIX DURING AMC DATA RETRIEVAL
;*
;* VALIDATION HISTORY:
;*      08 FEB 2011 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1/IDL 8.0: NOMINAL 
;*      14 APR 2011 - C KENT    - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                                COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION DIMITRI_VISUALISATION_REFLECTANCE,ED_FOLDER,VR_REGION,DIMITRI_BAND,REF_SENSOR,$
                                           REF_PROC_VER,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: STARTING RETRIEVAL OF DIMITRI REFLECTANCE DATA'

;--------------------------------
; FIND ALL CORRESPONDING DOUBLET 
; EXTRACTION FILES 
  
  REF_STR = 'ED_'+VR_REGION+'_'+REF_SENSOR+'_'+REF_PROC_VER+'*.dat'
  CAL_STR = 'ED_'+VR_REGION+'_*'+REF_SENSOR+'_'+REF_PROC_VER+'.dat'

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: SEARCHING FOR DOUBLET DATA'
  REF_FILES = FILE_SEARCH(ED_FOLDER,REF_STR)
  CAL_FILES = FILE_SEARCH(ED_FOLDER,CAL_STR)
  
  IF STRCMP(REF_FILES[0],'') EQ 1 OR $
     STRCMP(CAL_FILES[0],'') EQ 1 OR $
     (N_ELEMENTS(REF_FILES) NE N_ELEMENTS(CAL_FILES)) THEN BEGIN
    PRINT, 'DIMITRI_VISU_REFL: ERROR, NO DOUBLET DATA FOUND'
    RETURN,{ERROR:1}
  ENDIF

;-----------------------------------------
; RETRIEVE THE SITE TYPE

  SITE_TYPE = GET_SITE_TYPE(VR_REGION) 

;--------------------------------
; GET THE NUMBER OF REFERENCE/CALIBRATION 
; FILES AVAILABLE     
  
  NUM_REF_CONFIGS   = N_ELEMENTS(REF_FILES)
  NUM_CAL_CONFIGS   = N_ELEMENTS(CAL_FILES)
  NUM_SENS_CONFIGS  = 1+NUM_CAL_CONFIGS

;--------------------------------
; START LIST OF ALL SENSOR AND 
; PROCESSING VERSION CONFIGURATIONS, 
; AND REFERENCE SENSOR DATES AND 
; REFLECTANCE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: DEFINING SENSOR CONFIGURAITON ARRAY'
  SENSOR_CONFIGS  = STRING(REF_SENSOR+'_'+REF_PROC_VER)
  SENS_CONFIG_ABLE= MAKE_ARRAY(NUM_SENS_CONFIGS,/INTEGER,VALUE=0)
  TMP_REF_DATE    = DOUBLE(0.0)
  TMP_REF_REFL    = DOUBLE(0.0)

;-----------------------------------------
; MODISA SURFACE DEPENDANCE EXCEPTION

  IF REF_SENSOR EQ 'MODISA' THEN BEGIN
    IF STRUPCASE(SITE_TYPE) EQ 'OCEAN' THEN TEMP_SENSOR = REF_SENSOR+'_O' ELSE TEMP_SENSOR = REF_SENSOR+'_L'
  ENDIF ELSE TEMP_SENSOR = REF_SENSOR 
 
;--------------------------------  
; GET RELATED SENSOR INDEX BASED 
; ON DIMITRI BAND ID
  
  SENSOR_INDEX = GET_SENSOR_BAND_INDEX(TEMP_SENSOR,DIMITRI_BAND,VERBOSE=VERBOSE)

  IF SENSOR_INDEX LT 0 THEN BEGIN
    PRINT,'DIMITRI_VISU_REFL: ERROR, NO REFERENCE SENSOR VALUE FOR DIMITRI BAND'
    RETURN,{ERROR:1}
  ENDIF

;-------------------------------- 
; CONCATENATE DATE AND REFLECTANCE 
; INFO FOR REFERENCE SENSOR

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: CONCATENATING REFERENCE SENSOR INFORMATION'  
  NUM_NON_REFS = 5+12 ;(TIME, ANGLES (4) AND AUX INFO (12)
  FOR I=0,NUM_REF_CONFIGS-1 DO BEGIN
    RESTORE,REF_FILES[I]
    
    IF N_ELEMENTS(ED_SENSOR1_SENSOR2) EQ 0 THEN BEGIN
      MSG = ['DIMITRI_VISU_REFL ERROR:','','NO REFERENCE DATA FOR REQUESTED SENSOR CONFIGURATION','CLOSING...']
      RES = DIALOG_MESSAGE(MSG,TITLE = 'DIMITRI INTERNAL ERROR',/ERROR)
      RETURN,{ERROR:2}    
    ENDIF
     
    TEMP_ELEMENTS = N_ELEMENTS(ED_SENSOR1_SENSOR2[0,*])
    TMP_REF_DATE  = [TMP_REF_DATE,REFORM(ED_SENSOR1_SENSOR2[0,*],TEMP_ELEMENTS)]
    TMP_REF_REFL  = [TMP_REF_REFL,REFORM(DOUBLE(ED_SENSOR1_SENSOR2[NUM_NON_REFS+SENSOR_INDEX,*]),TEMP_ELEMENTS)]
  ENDFOR

;--------------------------------
; SORT VALUES INTO ASCENDING TIME 
    
  TEMP          = SORT(TMP_REF_DATE)
  TMP_REF_DATE  = TMP_REF_DATE[TEMP[1:N_ELEMENTS(TEMP)-1]]
  TMP_REF_REFL  = TMP_REF_REFL[TEMP[1:N_ELEMENTS(TEMP)-1]]
  NUM_REF_DATE  = N_ELEMENTS(TMP_REF_DATE)

;--------------------------------  
; CREATE AN ARRAY TO HOLD ALL TIME 
; AND REFLECTANCE DATA FOR EACH 
; SENSOR CONFIGURATION FOUND

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: DEFINING ARRAY TO HOLD ALL REFLECTANCE DATA'
  REFL_DATA         = MAKE_ARRAY(NUM_REF_DATE,NUM_SENS_CONFIGS,3,/DOUBLE)
  REFL_DATA[*,0,0]  = TMP_REF_DATE
  REFL_DATA[*,0,1]  = TMP_REF_REFL   
 
;-------------------------------- 
; RESTORE CAL FILES AND STORE 
; THE DATA  

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: STARTING LOOP ON ALL CAL-SENSOR FILES'
  SENS_CONFIG_ABLE[0] = 1
  FOR I=0,NUM_CAL_CONFIGS-1 DO BEGIN

;-------------------------------- 
; GET SENSOR CONFIGURATION FROM FILENAME

    POS   = STRPOS(CAL_FILES[I],VR_REGION,/REVERSE_SEARCH)+STRLEN(VR_REGION)+1
    POS1  = STRPOS(CAL_FILES[I],REF_SENSOR,/REVERSE_SEARCH)-1
    TMP   = STRMID(CAL_FILES[I],POS,POS1-POS)
    SENSOR_CONFIGS = [SENSOR_CONFIGS,TMP]
    RESTORE,CAL_FILES[I]

;--------------------------------
; GET SENSOR BAND INDEX

    SENS_NAME = STRSPLIT(TMP,'_',/EXTRACT)
    SENS_NAME = SENS_NAME[0]
    
;-----------------------------------------
; MODISA SURFACE DEPENDANCE EXCEPTION

    IF SENS_NAME EQ 'MODISA' THEN BEGIN
      IF STRUPCASE(SITE_TYPE) EQ 'OCEAN' THEN TEMP_SENSOR = SENS_NAME+'_O' ELSE TEMP_SENSOR = SENS_NAME+'_L'
    ENDIF ELSE TEMP_SENSOR = SENS_NAME     
    
    IDX = GET_SENSOR_BAND_INDEX(TEMP_SENSOR,DIMITRI_BAND)
    IF IDX LT 0 THEN GOTO,NEXT_FILE
    SENS_CONFIG_ABLE[1+I] = 1

;--------------------------------
; STORE TIME AND REFLECTANCE DATA

    TEMP_ELEMENTS = N_ELEMENTS(ED_SENSOR2_SENSOR1[0,*])
    NB_COLS = N_ELEMENTS(ED_SENSOR2_SENSOR1[*,0])
    TMP_DATE = DOUBLE(ED_SENSOR2_SENSOR1[0,*])
    TMP_REFL = DOUBLE(ED_SENSOR2_SENSOR1[NUM_NON_REFS+IDX,*])
    TMP_CHIV = DOUBLE(ED_SENSOR2_SENSOR1[NB_COLS-1,*])
    SORT_IDX = SORT(TMP_DATE)    

    REFL_DATA[0:TEMP_ELEMENTS-1,I+1,0] = TMP_DATE[SORT_IDX]
    REFL_DATA[0:TEMP_ELEMENTS-1,I+1,1] = TMP_REFL[SORT_IDX]
    REFL_DATA[0:TEMP_ELEMENTS-1,I+1,2] = TMP_CHIV[SORT_IDX]
    NEXT_FILE:

  ENDFOR

;--------------------------------
; CREATE ANOTHER SENSOR_ABLE ARRAY 
; BUT SET THE REFERNCE SENSOR AS 0

  SENS_CONFIG_ABLE_CHI = SENS_CONFIG_ABLE
  SENS_CONFIG_ABLE_CHI[0] = 0

;--------------------------------
; RETURN ALL DATA IN A STRUCTURE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_REFL: RETURNING REFLECTANCE DATA STRUCTURE'
  VISU_REFL = {                                             $
              ERROR:0                                       ,$
              DATA:REFL_DATA                                ,$
              NUM_SENS_CONFIGS:NUM_SENS_CONFIGS             ,$
              SENSOR_CONFIGS:SENSOR_CONFIGS                 ,$
              NUM_XELEMENTS:NUM_REF_DATE                    ,$
              SENS_CONFIG_ABLE_AMC:SENS_CONFIG_ABLE_CHI     ,$
              SENS_CONFIG_ABLE:SENS_CONFIG_ABLE             $
              }

  RETURN,VISU_REFL

END