;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      DIMITRI_DATABASE_STATS_WD     
;* 
;* PURPOSE:
;*      THIS IS THE MAIN PROGRAM FOR VIEWING STATISTICS OF THE DIMITRI DATABASE FILE. 
;*      THIS PROGRAM GENERATES A TEXT WIDGET CONTAINING THE BASIC DATABASE STATISTICS. 
;*      THE WIDGET CAN ALSO BE USED TO CALL DIMITRI_DATABASE_STATS_WD TO SHOW ACQUISITION 
;*      OF PRODUCTS FOR EACH SENSOR OVER A SITE. 
;*
;*      THIS FILE CONTAINS A NUMBER OF SMALLER PROGRAMS USED TO ALLOW SAVING AND 
;*      EXITING OF THE STATS WIDGET.
;*
;* CALLING SEQUENCE:
;*      DIMITRI_DATABASE_STATS_WD      
;*
;* INPUTS:
;*
;* KEYWORDS:
;*      GROUP_LEADER - THE ID OF ANOTHER WIDGET TO BE USED AS THE GROUP LEADER
;*      VERBOSE - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      NONE
;*
;* COMMON BLOCKS:
;*      DHMI_DATABASE - CONTAINS THE DATABASE DATA FOR THE DIMITRI HMI
;*
;* MODIFICATION HISTORY:
;*      17 FEB 2011 - C KENT    - DIMITRI-2 V1.0
;*      18 FEB 2011 - C KENT    - UPDATED PLOT DYNAMICS INCLUDING FONT SIZE
;*      25 FEB 2010 - C KENT    - ADDED GROUP_LEADER KEYWORD
;*      21 MAR 2011 - C KENT    - MODIFIED FILE DEFINITION TO USE GET_DIMITRI_LOCATION
;*      24 MAR 2011 - C KENT    - FIXED BUG IN LATEST MODIFICATION DATE COMPUTATION
;*      30 JUN 2011 - C KENT    - UPDATED CLOUD SCREENING TO INCLUDE SUSPECT FLAG
;*      06 JUL 2011 - C KENT    - ADDED DATABASE COMMON BLOCK TO DIMITRI HMI
;*      12 JUL 2011 - C KENT    - CORRECTD BUG ON UNIQ VALUE SEARCH
;*
;* VALIDATION HISTORY:
;*      17 FEB 2011 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1/IDL 8.0: NOMINAL 
;*      18 FEB 2011 - C KENT    - LINUX 64-BIT MACHINE IDL 8.0: NOMINAL BEHAVIOUR
;*      14 APR 2011 - C KENT    - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                                COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

PRO STATS_OBJECT_SAVE,EVENT

  WIDGET_CONTROL, EVENT.TOP,  GET_UVALUE=STATS_INFO, /NO_COPY
  WIDGET_CONTROL, EVENT.ID,   GET_UVALUE=ACTION

;-------------------------------------
; SELECTED FILENAME FOR OUTPUT

  IF STATS_INFO.VERBOSE EQ 1 THEN PRINT,'DIMITRI_DATABASE_STATS->SAVE: DEFINING OUTPUT FILE' 
  FILENAME = DIALOG_PICKFILE(/WRITE,FILE='DATABASE_STATS.txt',/OVERWRITE_PROMPT)
  IF FILENAME EQ '' THEN GOTO, NO_OUTPUT

  IF STATS_INFO.VERBOSE EQ 1 THEN PRINT,'DIMITRI_DATABASE_STATS->SAVE: PRINTING DATA TO OUTPUT FILE' 
  OPENW,OUTF,FILENAME,/GET_LUN
  FOR I=0,N_ELEMENTS(STATS_INFO.STATS_STR_TXT)-1 DO PRINTF,OUTF,STATS_INFO.STATS_STR_TXT[I]
  FREE_LUN,OUTF

;-------------------------------------
; RETURN TO THE WIDGET WITH NO CHANGES

  NO_OUTPUT:
  WIDGET_CONTROL, EVENT.TOP,SET_UVALUE=STATS_INFO,/NO_COPY

END

;**************************************************************************************
;**************************************************************************************

PRO STATS_OBJECT_EXIT,EVENT

  WIDGET_CONTROL, EVENT.TOP, GET_UVALUE = STATS_INFO, /NO_COPY
  WIDGET_CONTROL, EVENT.TOP, /DESTROY
  IF STATS_INFO.VERBOSE EQ 1 THEN PRINT,'DIMITRI_DATABASE_STATS->EXIT: CLOSING THE STATS WIDGET'
    
END

;**************************************************************************************
;**************************************************************************************

PRO STATS_OBJECT_PLOT,EVENT

  WIDGET_CONTROL, EVENT.TOP, GET_UVALUE=STATS_INFO, /NO_COPY
  WIDGET_CONTROL, EVENT.ID,  GET_UVALUE=ACTION

;-------------------------------------
; CALL THE DATABASE PLOTTING PROCEDURE

  IF STATS_INFO.VERBOSE EQ 1 THEN PRINT,'DIMITRI_DATABASE_STATS->PLOT: CALLING THE PLOT WIDGET' 
  ;DIMITRI_DATABASE_PLOTS_WD,STATS_INFO.DB_DATA,ACTION,EVENT.TOP,VERBOSE=STATS_INFO.VERBOSE
  DIMITRI_DATABASE_PLOTS_WD,ACTION,EVENT.TOP,VERBOSE=STATS_INFO.VERBOSE

;-------------------------------------
; RETURN TO THE WIDGET WITH NO CHANGES

  WIDGET_CONTROL, EVENT.TOP,SET_UVALUE=STATS_INFO,/NO_COPY

END

;**************************************************************************************
;**************************************************************************************

PRO DIMITRI_DATABASE_STATS_WD,VERBOSE=VERBOSE,GROUP_LEADER=GROUP_LEADER

IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: STARTING STATISTICS MODULE'
COMMON DHMI_DATABASE

;------------------------------------ 
; GET THE DISPLAY RESOLUTION FOR WIDGET POSITIONING

  IF STRUPCASE(!VERSION.OS_FAMILY) EQ 'WINDOWS' THEN WIN_FLAG = 1 ELSE WIN_FLAG = 0
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: RETRIEVING SCREEN PARAMETERS FOR WIDGET'
  DIMS  = GET_SCREEN_SIZE()
  XSIZE = 315
  IF WIN_FLAG THEN YSIZE = 265 ELSE YSIZE=285
  XLOC  = (DIMS[0]/2)-(XSIZE/2)
  YLOC  = (DIMS[1]/2)-(YSIZE/2)

;------------------------------------ 
; FIND THE NUMBER OF UNIQ SITES, 
; SENSORS & PROC VERSIONS

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: RETRIEVING UNIQ SITES AND SENSOR CONFIGURATIONS'
  UNIQ_SITES  = DHMI_DB_DATA.REGION(UNIQ(DHMI_DB_DATA.REGION))
  NUM_SITES   = STRTRIM(STRING(N_ELEMENTS(UNIQ_SITES)),2)
  NUM_SENSOR  = STRTRIM(STRING(N_ELEMENTS(UNIQ(DHMI_DB_DATA.SENSOR,sort(DHMI_DB_DATA.SENSOR)))),2)
  NUM_PROCVER = STRTRIM(STRING(N_ELEMENTS(UNIQ(DHMI_DB_DATA.PROCESSING_VERSION,sort(DHMI_DB_DATA.PROCESSING_VERSION)))),2)

;------------------------------------ 
; FIND TOTAL NUMBER OF PRODUCTS INGESTED, 
; DATE RANGE OF PRODUCTS AND MANUAL 
; CLOUD SCREENING STATS

  IF KEYWORD_SET(VERBOSE) THEN $
    PRINT,'DIMITRI_DATABASE_STATS: RETRIEVING NUMBER OF PRODUCTS, DATE RANGE AND CLOUD SCREENING STATS'
  
  NUM_PRDS      = STRTRIM(STRING(N_ELEMENTS(DHMI_DB_DATA.DIMITRI_DATE)),2)
  DB_START_DATE = MIN(DHMI_DB_DATA.DECIMAL_YEAR,MAX = DB_END_DATE)
  DB_START_DATE = STRTRIM(STRING(DB_START_DATE) ,2)
  DB_END_DATE   = STRTRIM(STRING(DB_END_DATE)   ,2)
  
  RES           = WHERE(DHMI_DB_DATA.MANUAL_CS EQ  0,MAN_CS_PASS)
  RES           = WHERE(DHMI_DB_DATA.MANUAL_CS EQ  1,MAN_CS_FAIL)
  RES           = WHERE(DHMI_DB_DATA.MANUAL_CS EQ  2,MAN_CS_SUSP)
  RES           = WHERE(DHMI_DB_DATA.MANUAL_CS EQ -1,MAN_CS_UNKNOWN)
  MAN_CS_PASS   = STRTRIM(STRING(MAN_CS_PASS)   ,2)
  MAN_CS_FAIL   = STRTRIM(STRING(MAN_CS_FAIL)   ,2)
  MAN_CS_UNKNOWN= STRTRIM(STRING(MAN_CS_UNKNOWN),2)
  MAN_CS_SUSP   = STRTRIM(STRING(MAN_CS_SUSP)   ,2)

;------------------------------------
; FIND UNIQ MODIFICATION DATES, THEN 
; LOOP THROUGH AND FIND THE LATEST DATE

  UNIQ_DDATES   = DHMI_DB_DATA.DIMITRI_DATE[UNIQ(DHMI_DB_DATA.DIMITRI_DATE,SORT(DHMI_DB_DATA.DIMITRI_DATE))]
  LATEST_DATE   = UNIQ_DDATES[0]
  LATEST_DATEN  = 0
  MNTHS         = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: STARTING LOOP TO FIND LATEST MODIFICATION DATE'
  FOR I=0L,N_ELEMENTS(UNIQ_DDATES)-1 DO BEGIN
    TEMP_YY = FIX(STRMID(UNIQ_DDATES[i],7,4))
    TEMP_DD = FIX(STRMID(UNIQ_DDATES[i],0,2))
    TEMP_MM = STRMID(UNIQ_DDATES[i],3,3)
    RES     = WHERE(STRCMP(MNTHS,TEMP_MM) EQ 1)

    IF RES[0] GT -1 THEN TEMP_MM = RES[0]+1 ELSE TEMP_MM=1
    IF JULDAY(TEMP_MM,TEMP_DD,TEMP_YY) GT LATEST_DATEN THEN $
      LATEST_DATEN = JULDAY(TEMP_MM,TEMP_DD,TEMP_YY)
  ENDFOR

;------------------------------------
; STORE THE LATEST DATE AS DD/MM/YYYY

  CALDAT,LATEST_DATEN,LMM,LDD,LYY
  LMM   = LMM lt 10. ? '0'+STRTRIM(STRING(LMM),2):STRTRIM(STRING(LMM),2) 
  LDD   = LDD lt 10. ? '0'+STRTRIM(STRING(LDD),2):STRTRIM(STRING(LDD),2)
  LYY   = STRTRIM(STRING(LYY),2)
  LDATE = LDD+'/'+LMM+'/'+LYY

;------------------------------------
; DEFINE THE STATS STRING FOR THE WIDGET, 
; AND A SEPARATE VERSION FOR SAVING A TXT

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: DEFINING STATS STRING FOR WIDGET AND TEXT FILE'
  STATS_STR=[                                                                                 $
            '                                       '                                         ,$
            ' NUMBER OF SITES            = '  + NUM_SITES                                     ,$
            ' NUMBER OF SENSORS     = '       + NUM_SENSOR                                    ,$
            ' NUMBER OF L1B DATA     = '      + NUM_PRDS                                      ,$
            ' FIRST PRODUCT DATE     = '      + DB_START_DATE                                 ,$
            ' LAST PRODUCT DATE      = '      + DB_END_DATE                                   ,$
            '                                       '                                         ,$                          
            ' -------------------------------------------------------------------------- '    ,$    
            '                                       '                                         ,$ 
            ' MANUAL CLOUD SCREENING:               '                                         ,$
            '                                       '                                         ,$
            ' NUMBER OF PASSES         = '    + MAN_CS_PASS                                   ,$
            ' NUMBER OF FAILS             = ' + MAN_CS_FAIL                                   ,$
            ' NUMBER OF SUSPECT      = '    + MAN_CS_SUSP                                   ,$
            ' NUMBER OF UNKNOWNS = '    + MAN_CS_UNKNOWN                                ,$
            '                                '                                                ,$
            ' -------------------------------------------------------------------------- '    ,$
            '                                       '                                         ,$ 
            ' DATABASE LAST UPDATED ON '      + LDATE                                         ,$            
            '                                       '                                         ]
  
  STATS_STR_TXT=[                                                                             $
            '                                       '                                         ,$
            ' NUMBER OF SITES     = '         + NUM_SITES                                     ,$
            ' NUMBER OF SENSORS   = '         + NUM_SENSOR                                    ,$
            ' NUMBER OF L1B DATA  = '         + NUM_PRDS                                      ,$
            ' FIRST PRODUCT DATE  = '         + DB_START_DATE                                 ,$
            ' LAST PRODUCT DATE   = '         + DB_END_DATE                                   ,$
            '                                       '                                         ,$                          
            ' -------------------------------------------------------------------------- '    ,$    
            '                                       '                                         ,$ 
            ' MANUAL CLOUD SCREENING:               '                                         ,$
            '                                       '                                         ,$
            ' NUMBER OF PASSES    = '         + MAN_CS_PASS                                   ,$
            ' NUMBER OF FAILS     = '         + MAN_CS_FAIL                                   ,$
            ' NUMBER OF SUSPECT   = '         + MAN_CS_SUSP                                   ,$
            ' NUMBER OF UNKNOWNS  = '         + MAN_CS_UNKNOWN                                ,$
            '                                '                                                ,$
            ' -------------------------------------------------------------------------- '    ,$
            '                                       '                                         ,$ 
            ' DATABASE LAST UPDATED ON '      + LDATE                                         ,$            
            '                                       '                                         ]

;------------------------------------
; DEFINE THE WIDGET AND MENU BARS

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: DEFINING THE BASE WIDGET AND BUTTONS'
  DB_STATS_WD   = WIDGET_BASE(/COLUMN,XSIZE=XSIZE,YSIZE=YSIZE,XOFFSET=XLOC,YOFFSET=YLOC,$
                              TITLE='DIMITRI V2.0 DATABASE STATISTICS',MBAR=ST_MENUBASE)
  STATS_WD_DLIM = WIDGET_BUTTON(ST_MENUBASE,      VALUE='||'  ,SENSITIVE=0)
  STATS_WD_FILE = WIDGET_BUTTON(ST_MENUBASE,      VALUE='File',/MENU)
  STATS_WD_DLIM = WIDGET_BUTTON(ST_MENUBASE,      VALUE='||'  ,SENSITIVE=0)
  STATS_WD_VIEW = WIDGET_BUTTON(ST_MENUBASE,      VALUE='Acquisition Plots',/MENU)
  STATS_WD_EXPT = WIDGET_BUTTON(STATS_WD_FILE,    VALUE='Save',EVENT_PRO='STATS_OBJECT_SAVE')
  STATS_WD_EXIT = WIDGET_BUTTON(STATS_WD_FILE,    VALUE ='Exit',/SEPARATOR,EVENT_PRO='STATS_OBJECT_EXIT')
  
  CASE STRUPCASE(!VERSION.OS_FAMILY) OF 
    'WINDOWS': DB_STATS_TEXT = WIDGET_TEXT(DB_STATS_WD,VALUE=STATS_STR,YSIZE=20)
    'UNIX':  DB_STATS_TEXT = WIDGET_TEXT(DB_STATS_WD,VALUE=STATS_STR_TXT,YSIZE=20)
  ELSE: DB_STATS_TEXT = WIDGET_TEXT(DB_STATS_WD,VALUE=STATS_STR,YSIZE=20)
  ENDCASE
  
;------------------------------------
; ADD BUTTONS FOR EACH AVAILABLE CONFIG

  FOR I=0,N_ELEMENTS(UNIQ_SITES)-1 DO BEGIN
    STATS_WD_PLOT = WIDGET_BUTTON(STATS_WD_VIEW,VALUE=UNIQ_SITES[I],UVALUE=UNIQ_SITES[I],$
                                  EVENT_PRO='STATS_OBJECT_PLOT')
  ENDFOR
  IF KEYWORD_SET(VERBOSE) THEN VERBOSE = 1 ELSE VERBOSE = 0

  STATS_INFO = {                                $
               STATS_STR      : STATS_STR       ,$
               STATS_STR_TXT  : STATS_STR_TXT   ,$
               UNIQ_SITES     : UNIQ_SITES      ,$
               VERBOSE        : VERBOSE         $;,$
               ;DB_DATA        : DB_DATA         $
               }

;------------------------------------
; REALISE THE WIDGET, SET THE VALUES 
; AND REGISTER WITH THE XMANAGER

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_DATABASE_STATS: STARTING THE STATS WIDGET'  
  IF KEYWORD_SET(GROUP_LEADER) THEN WIDGET_CONTROL, DB_STATS_WD, /REALIZE,SET_UVALUE=STATS_INFO,/NO_COPY,GROUP_LEADER=GROUP_LEADER $
  ELSE WIDGET_CONTROL, DB_STATS_WD, /REALIZE,SET_UVALUE=STATS_INFO,/NO_COPY

  XMANAGER,'STATS_OBJECT', DB_STATS_WD

END