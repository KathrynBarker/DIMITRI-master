;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI TEMPLATE       
;* 
;* PURPOSE:
;*      RETURNS THE DATABASE STRUCTURE, HEADER OR TEMPLATE DEPENDING ON KEYWORD
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_TEMPLATE(NB_FILES)      
;* 
;* INPUTS:
;*      NB_FILES - THE NUMBER OF INPUT FILES. 
;*
;* KEYWORDS:
;*      DB        - SET TO RETRIEVE THE DATABASE STRUCTURE 
;*      HDR       - SET TO RETRIEVE THE DATABASE HEADER
;*      TEMPLATE  - SET TO RETRIEVE THE DATABASE TEMPLATE
;*      FORMAT    - SET TO RETRIEVE THE DATABASE FORMAT
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*      
;* OUTPUTS:
;*      A STRUCTURE, HEADER OR TEMPLATE DEPENDING ON KEYWORDS 
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      22 NOV 2010 - C KENT    - DIMITRI-2 V1.0
;*      01 DEC 2010 - C KENT    - ADDED VERBOSE KEYWORD
;*      02 DEC 2010 - C KENT    - UPDATED HEADER INFORMATION
;*      08 MAR 2012 - C KENT    - ADDED ROI COVER
;*
;* VALIDATION HISTORY:
;*      01 DEC 2010 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION SUCCESSFUL,
;*                                VERBOSE COMMENTS,TESTED NB_FILES ERROR CATCH,
;*                                DATABASE STRUCTURE RETRIEVAL,HEADER RETRIEVAL,
;*                                TEMPLATE RETRIEVAL,FORMAT RETRIEVAL,NO_KEYWORD ERROR  
;*      12 APR 2011 - C KENT    - LINUX 64-BIT IDL 8.0: NOMINAL COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_TEMPLATE,NB_FILES,DB=DB,HDR=HDR,TEMPLATE=TEMPLATE,FORMAT=FORMAT,VERBOSE=VERBOSE

;-----------------------------------------
; CHECK NUMBER OF FILES SUPPLIED

  IF NB_FILES LT 1 THEN BEGIN
    PRINT, 'DIMITRI_TEMPLATE: ERROR, NUMBER OF FILES SET TO BELOW 1'
    RETURN,-1
  ENDIF

;-----------------------------------------
; IF REQUESTED, DEFINE AND RETURN THE DATABASE STRUCTURE

  IF KEYWORD_SET(DB) THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_TEMPLATE: RETRIEVING DATABASE STRUCTURE'
    DB_DATA = {$
              DIMITRI_DATE        : STRARR(NB_FILES),$
              REGION              : STRARR(NB_FILES),$
              SENSOR              : STRARR(NB_FILES),$
              PROCESSING_VERSION  : STRARR(NB_FILES),$
              YEAR                : INTARR(NB_FILES),$
              MONTH               : INTARR(NB_FILES),$
              DAY                 : INTARR(NB_FILES),$
              DOY                 : INTARR(NB_FILES),$
              DECIMAL_YEAR        : DBLARR(NB_FILES),$
              FILENAME            : STRARR(NB_FILES),$
              ROI_COVER           : INTARR(NB_FILES),$
              NUM_ROI_PX          : DBLARR(NB_FILES),$
              AUTO_CS             : DBLARR(NB_FILES),$
              MANUAL_CS           : INTARR(NB_FILES),$
              AUX_DATA_1          : STRARR(NB_FILES),$
              AUX_DATA_2          : STRARR(NB_FILES),$
              AUX_DATA_3          : STRARR(NB_FILES),$
              AUX_DATA_4          : STRARR(NB_FILES),$
              AUX_DATA_5          : STRARR(NB_FILES),$
              AUX_DATA_6          : STRARR(NB_FILES),$
              AUX_DATA_7          : STRARR(NB_FILES),$
              AUX_DATA_8          : STRARR(NB_FILES),$
              AUX_DATA_9          : STRARR(NB_FILES),$
              AUX_DATA_10         : STRARR(NB_FILES) $
            }
     ;IF KEYWORD_SET(VERBOSE) THEN HELP,DB_DATA
     RETURN, DB_DATA
   ENDIF

;-----------------------------------------
; IF REQUESTED, DEFINE AND RETURN THE DATABASE HEADER

  IF KEYWORD_SET(HDR) THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_TEMPLATE: RETRIEVING DATABASE HEADER'
    DB_HEAD =  STRING('DIMITRI_DATE;REGION;SENSOR;PROCESSING_VERSION;'+$
                      'YEAR;MONTH;DAY;DOY;DECIMAL_YEAR;'+$
                      'FILENAME;ROI_COVER;NUM_ROI_PX;AUTO_CS;MANUAL_CS;'+$
                      'AUX_DATA_1;AUX_DATA_2;AUX_DATA_3;AUX_DATA_4;AUX_DATA_5;'+$
                      'AUX_DATA_6;AUX_DATA_7;AUX_DATA_8;AUX_DATA_9;AUX_DATA_10')
    IF KEYWORD_SET(VERBOSE) THEN HELP, DB_HEAD
    RETURN, DB_HEAD
  ENDIF

;-----------------------------------------
; IF REQUESTED, DEFINE AND RETURN THE DATABASE TEMPLATE

  IF KEYWORD_SET(TEMPLATE) THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_TEMPLATE: RETRIEVING DATABASE TEMPLATE'
    DB_NAME=['DIMITRI_DATE','REGION','SENSOR','PROCESSING_VERSION',$
             'YEAR','MONTH','DAY','DOY','DECIMAL_YEAR',$
             'FILENAME','ROI_COVER','NUM_ROI_PX','AUTO_CS','MANUAL_CS',$
             'AUX_DATA_1','AUX_DATA_2','AUX_DATA_3','AUX_DATA_4','AUX_DATA_5',$
             'AUX_DATA_6','AUX_DATA_7','AUX_DATA_8','AUX_DATA_9','AUX_DATA_10']

    DB_TYPE=[7,7,7,7,  $
             3,3,3,3,5,$
             7,3,5,5,3,  $
             7,7,7,7,7,$
             7,7,7,7,7 ]  
    
    DB_TEMPLATE={    VERSION        : 1.0                       , $
                     DATASTART      : 1 , $
                     DELIMITER      : ';' , $
                     MISSINGVALUE   : !values.f_NaN, $
                     COMMENTSYMBOL  : ''          , $
                     FIELDCOUNT     : N_ELEMENTS(DB_NAME), $
                     FIELDTYPES     : DB_TYPE, $
                     FIELDNAMES     : DB_NAME, $
                     FIELDLOCATIONS : INDGEN(N_ELEMENTS(DB_NAME)), $
                     FIELDGROUPS    : [INDGEN(N_ELEMENTS(DB_NAME))]}
    ;IF KEYWORD_SET(VERBOSE) THEN HELP,DB_TEMPLATE       
    RETURN, DB_TEMPLATE
  ENDIF

;-----------------------------------------
; IF REQUESTED, DEFINE AND RETURN THE DATABASE FORMAT

  IF KEYWORD_SET(FORMAT) THEN BEGIN
    IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_TEMPLATE: RETRIEVING DATABASE FORMAT CODE'
    DB_FORMAT = '(4(A,1H;),4(I4,1H;),1(D20.12,1H;),1(A,1H;),1(I3,1H;),1(D15.1,1H;),1(D6.3,1H;),1(I3,1H;),9(A,1H;),1(A))'
     IF KEYWORD_SET(VERBOSE) THEN HELP,DB_FORMAT   
    RETURN, DB_FORMAT
  ENDIF

;-----------------------------------------
; IF NO KEYWORDS THEN RETURN AN ERROR

  RETURN,-1

END
