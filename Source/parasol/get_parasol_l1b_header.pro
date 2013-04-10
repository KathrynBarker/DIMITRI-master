;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_PARASOL_L1B_HEADER       
;* 
;* PURPOSE:
;*      RETURNS THE HEADER DATA FOR A SPECIFIC PARASOL PRODUCT
;* 
;* CALLING SEQUENCE:
;*      RES = GET_PARASOL_L1B_HEADER(FILENAME)      
;* 
;* INPUTS:
;*      FILENAME - A SCALAR CONTAINING THE FILENAME OF THE PRODUCT TO BE READ 
;*
;* KEYWORDS:
;*      VERBOSE     - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      L1B_DATA    - A STRUCTURE CONTAINING THE HEADER INFORMATION 
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*             2005 - M BOUVET - PROTOTYPE DIMITRI VERSION
;*      15 DEC 2010 - C KENT   - DIMITRI-2 V1.0
;*      14 JUL 2011 - C KENT   - UPDATED TIME EXTRACTION SECTION
;*      29 FEB 2012 - C KENT   - ADDED SEQUENCE TIME EXTRACTION
;*
;* VALIDATION HISTORY:
;*      10 JAN 2011 - C KENT   - WINDOWS 32 BIT MACHINE, IDL 7.1: COMPILATION AND 
;*                               RUNNING SUCCESSFUL, RESULTS NOMINAL
;*                             - LINUX 64-BIT MACHINE, IDL 8.0: COMPILATION SUCESSFUL, 
;*                               RESULTS EQUAL TO WINDOWS MACHINE 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_PARASOL_L1B_HEADER,FILENAME,VERBOSE=VERBOSE

;------------------------
; FILENAME PARAMETER CHECK

  IF STRCMP(FILENAME,'') THEN BEGIN
    PRINT, 'PARASOL L1B HEADER: NO INPUT FILES PROVIDED, RETURNING...'
    RETURN,-1
  ENDIF  
  
;-----------------------------------------------
; CHECK FILENAME OS A PARASOL DATA FILE

  TEMP = STRMATCH(FILENAME,'*P3L1TBG*D*')
  IF TEMP EQ 0 THEN BEGIN
    PRINT, 'PARASOL L1B HEADER: ERROR, INPUT FILE NOT A PARASOL DATA FILE'
    RETURN,-1
  ENDIF

;------------------------------------------------
; CONVERT FILENAME TO HEADER FILENAME

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'PARASOL L1B HEADER: COMPUTING LEADER FILE FROM INPUT FILENAME'
  TEMP = STRPOS(FILENAME,'P3L1TBG',/REVERSE_SEARCH)
  HDR_FILE = FILENAME
  STRPUT,HDR_FILE,'L',TEMP+15

;------------------------------------------------
; CHECK THAT THE FILE EXISTS

  TEMP = FILE_INFO(HDR_FILE)
  IF TEMP.EXISTS EQ 0 THEN BEGIN
    PRINT, 'PARASOL L1B DATA: ERROR, INPUT FILE DOES NOT EXIST'
    RETURN,-1
  ENDIF

;------------------------------------------------
; DEFINE HEADER STRUCTURE

  L1B_HEADER = {$
              DATE:STRARR(1),$
              SOFTWARE_VERSION:STRARR(1),$
              DEM_MODEL:STRARR(1),$
              RAD_DATE:STRARR(1),$
              GEO_DATE:STRARR(1), $
              SEQ_DATE:STRARR(130,9), $
              SCL_FACT:FLTARR(16,9), $
              OFF_FACT:FLTARR(16,9) $
              }

;------------------------------------------------
; OPEN THE PRODUCT 

  OPENR,IN_PARA,HDR_FILE,/GET_LUN
  
;------------------------------------------------
; DEFINE TEMPORARY VARIABLES FOR READING

  TEMP_SSI = INTARR(1)
  TEMP_USI = UINTARR(1)
  TEMP_ULI = ULONARR(1)
  TEMP_BYT = BYTARR(16)
  TEMP_REF = INTARR(15)

;------------------------------------------------
; RETIREVE THE PRODUCT DATE

  POINT_LUN,IN_PARA,180+360+100
  TEMP = BYTARR(16)
  READU,IN_PARA,TEMP
  L1B_HEADER.DATE = STRING(TEMP)

;------------------------------------------------
; RETIREVE THE SOFTWARE VERSION

  POINT_LUN,IN_PARA,26
  TEMP = BYTARR(6)
  READU,IN_PARA,TEMP
  L1B_HEADER.SOFTWARE_VERSION = STRING('VERSION_'+STRING(TEMP))

;------------------------------------------------
; RETIREVE THE DEM VERSION

  POINT_LUN,IN_PARA,180+134
  TEMP = BYTARR(30)
  READU,IN_PARA,TEMP
  L1B_HEADER.DEM_MODEL = STRING(TEMP)

;------------------------------------------------
; RETIREVE THE RAD VERSION

  POINT_LUN,IN_PARA,180+360+1620+180+166320+296
  TEMP = BYTARR(16)
  READU,IN_PARA,TEMP
  L1B_HEADER.RAD_DATE = STRING('RAD_'+STRMID(STRING(TEMP),0,8))  
 
;------------------------------------------------
; RETIREVE THE GEO VERSION

  POINT_LUN,IN_PARA,180+360+1620+180+166320+336
  TEMP = BYTARR(16)
  READU,IN_PARA,TEMP
  L1B_HEADER.GEO_DATE = STRING('GEO_'+STRMID(STRING(TEMP),0,8))      
  
;------------------------------------------------
; GET DATE OF EACH SEQUENCE IN PRODUCT

  SKIP = 180+360+1620+180
  FOR ISEQ = 1,130 DO BEGIN
    POINT_LUN,IN_PARA,SKIP+1278l*(ISEQ-1)+8
    SEQN = BYTARR(4)
    READU,IN_PARA,SEQN
    SEQN = STRING(SEQN)
    
    FOR ISEQB=1,9 DO BEGIN
      POINT_LUN,IN_PARA,SKIP+1278L*(ISEQ-1)+138L*(ISEQB-1)+46
      TEMP = BYTARR(16)
      READU,IN_PARA,TEMP
      L1B_HEADER.SEQ_DATE[(FIX(SEQN)-1)>0,(ISEQB-1)] = STRMID(STRING(TEMP),0,14) ; YYYYMMDDHHMNSS
    ENDFOR
  ENDFOR

;------------------------------------------------ 
; GET SCALING FACTORS

   SKIP = 180+360+1620+180+166320+720
   FOR IPD=0,15 DO BEGIN
     FOR IPB=0,8 DO BEGIN   
       PNUM = 23*(IPD+1)+(IPB-9)
       POINT_LUN,IN_PARA,SKIP+26*(PNUM-1)+46
       TEMP = BYTARR(12)
       READU,IN_PARA,TEMP
       L1B_HEADER.SCL_FACT[IPD,IPB] = FLOAT(STRING(TEMP))
    
       POINT_LUN,IN_PARA,SKIP+26*(PNUM-1)+48
       TEMP = BYTARR(12)
       READU,IN_PARA,TEMP
       L1B_HEADER.OFF_FACT[IPD,IPB] = FLOAT(STRING(TEMP))
     ENDFOR
   ENDFOR
 
;------------------------------------------------
; CLOSE THE PRODUCT

  FREE_LUN, IN_PARA 
 
;------------------------------------------------
; RETURN THE HEADER INFORMATION

  RETURN,L1B_HEADER

END