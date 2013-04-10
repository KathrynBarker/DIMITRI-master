;+
; NAME: 
;    AATSR_READ_DRIFT_TABLE
;    
; PURPOSE: 
;    Reads AATSR Visible Channel Drift Corrections from Look-Up-Table
; 
; CATEGORY:
;    Function
; 
; CALLING SEQUENCE:
;    NTAB = AATSR_READ_DRIFT_TABLE(DRIFT_TABLE)
;
; INPUT:
;    None
; 
; KEYWORD PARAMETERS:
;    PATH - Text String Containing Path to cal table - default is R:\dls47\validation\Visible Calibration Drift Tables\
;    FILE - Text String Containing Name of cal file to be used - default is latest version
;
; OUTPUT:
;    DRIFT_TABLE - Structure containing calibration drift table
;    NTAB - Returned value containing number of elements in table - value set to -1 if an error occurs
;
; Modification History:
;   Written By: Dave Smith RAL - 16-JAN-2008
;   28-Jan-2011 - Allows to read new version of table with errors 
;                 Square brackets used for array indices for compatibility with idl8
;   03-Mar-2011 - Header updated
;   05-May-2011 - Version and creation date added to output structure
;   23-JUN-2011 - For Loop for reading header replaced by while to search for string '#'
;   
;$Id: AATSR_READ_DRIFT_TABLE.PRO 214 2011-08-05 13:19:32Z dlsmith $
;-
;******************************************************************************************************************

FUNCTION AATSR_READ_DRIFT_TABLE,DRIFT_TABLE,PATH=PATH,FILE=FILE

    CHAN = ['0.56um','0.66um','0.87um','1.6um']
    V16 = 3
    V87 = 2
    V66 = 1
    V56 = 0
    ERROR = -1
    LINE = ' '

    NMAX =5000

    DRIFT_TABLE = {NTAB: 0U, $
                   VERSION: '00-00', $
                   CREATED: '01-JAN-2000 00:00:00', $
                   DATE_STR:  STRARR(NMAX), $
                   DATE_JUL:  DBLARR(NMAX), $
                   V56_DRIFT: DBLARR(NMAX), $
                   V56_ERROR: DBLARR(NMAX), $
                   V67_DRIFT: DBLARR(NMAX), $
                   V67_ERROR: DBLARR(NMAX), $
                   V87_DRIFT: DBLARR(NMAX), $
                   V87_ERROR: DBLARR(NMAX), $
                   V16_DRIFT: DBLARR(NMAX), $
                   V16_ERROR: DBLARR(NMAX) $
                   }

;******************************************************************************************************************
;If path is not present then set to default
;    IF(N_ELEMENTS(PATH) EQ 0)THEN BEGIN;
;        RESULT = SET_CALVAL_TOOLS_ENV()
;        PATH = GETENV('CALVAL_TABLE')+'\'
;    ENDIF

;Check that path is valid
    RESULT = FILE_TEST(PATH)
    IF(RESULT EQ 0)THEN BEGIN
       PRINT,'ERROR: Path Not Found: ',PATH
       RETURN,ERROR
    ENDIF

;If file is not present then set to default
    IF(N_ELEMENTS(FILE) EQ 0)THEN BEGIN
        RESULT = FILE_SEARCH(PATH+'AATSR_VIS_DRIFT*.DAT',COUNT=NF)
        IF(NF EQ 0)THEN BEGIN
           PRINT,'ERROR: No Files found in ',PATH
           RETURN,ERROR
        ENDIF
        FILE = RESULT(NF-1)
        FILE = STRMID(FILE,STRLEN(PATH))
    ENDIF

;Now open the file
    OPENR,U,PATH+FILE,/GET_LUN,ERROR=ERR
    IF(ERR NE 0)THEN BEGIN
    ; If err is nonzero, something happened. Print the error message to
    ; the standard error file (logical unit -2):
      PRINTF, -2, !ERROR_STATE.MSG
      RETURN,-1
    ENDIF
    NTAB = -1

;Read the file header
    REPEAT BEGIN 
        READF,U,LINE
        TAB = STRTRIM(STRMID(LINE,0,STRPOS(LINE,':')),2)
        CASE(TAB)OF 
          'Version':DRIFT_TABLE.VERSION =  STRTRIM(STRMID(LINE,STRPOS(LINE,':')+1),2)
          'File Generated':DRIFT_TABLE.CREATED = STRTRIM(STRMID(LINE,STRPOS(LINE,':')+1),2)
          ELSE: 
        ENDCASE
        START = STRPOS(LINE,'     #')
    ENDREP UNTIL((START NE -1) OR EOF(U))

;Now read the data
    WHILE(NOT EOF(U))DO BEGIN
       READF,U,LINE
       DATAIN = STRSPLIT(LINE,/EXTRACT,COUNT=NS)
       IF(NS EQ 7)THEN BEGIN
          NTAB = UINT(DATAIN[0])
          DRIFT_TABLE.DATE_STR[NTAB] = DATAIN[1] + ' ' + DATAIN[2]
          DRIFT_TABLE.DATE_JUL[NTAB] = TIMESTR_TO_JULDAY(DRIFT_TABLE.DATE_STR[NTAB])
          DRIFT_TABLE.V56_DRIFT[NTAB] = DOUBLE(DATAIN[3])
          DRIFT_TABLE.V67_DRIFT[NTAB] = DOUBLE(DATAIN[4])
          DRIFT_TABLE.V87_DRIFT[NTAB] = DOUBLE(DATAIN[5])
          DRIFT_TABLE.V16_DRIFT[NTAB] = DOUBLE(DATAIN[6])
       ENDIF
       IF(NS EQ 11)THEN BEGIN                                           ;Read version of table with errors
          NTAB = UINT(DATAIN[0])
          DRIFT_TABLE.DATE_STR[NTAB] = DATAIN[1] + ' ' + DATAIN[2]
          DRIFT_TABLE.DATE_JUL[NTAB] = TIMESTR_TO_JULDAY(DRIFT_TABLE.DATE_STR[NTAB])
          DRIFT_TABLE.V56_DRIFT[NTAB] = DOUBLE(DATAIN[3])
          DRIFT_TABLE.V56_ERROR[NTAB] = DOUBLE(DATAIN[4])
          DRIFT_TABLE.V67_DRIFT[NTAB] = DOUBLE(DATAIN[5])
          DRIFT_TABLE.V67_ERROR[NTAB] = DOUBLE(DATAIN[6])
          DRIFT_TABLE.V87_DRIFT[NTAB] = DOUBLE(DATAIN[7])
          DRIFT_TABLE.V87_ERROR[NTAB] = DOUBLE(DATAIN[8])
          DRIFT_TABLE.V16_DRIFT[NTAB] = DOUBLE(DATAIN[9])
          DRIFT_TABLE.V16_ERROR[NTAB] = DOUBLE(DATAIN[10])
       ENDIF
    ENDWHILE

    DRIFT_TABLE.NTAB = NTAB
    
;Close the file and tidy up
    CLOSE,U
    FREE_LUN,U

RETURN,NTAB


END

