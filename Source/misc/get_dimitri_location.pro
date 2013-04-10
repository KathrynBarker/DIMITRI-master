;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_LOCATION 
;* 
;* PURPOSE:
;*      PROVIDES THE HARD CODED LOCATION OF DIMITRI FOLDERS AND FILES RELATIVE TO 
;*      THE MAIN DIMITRI FOLDER.
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_LOCATION(LOCATION)      
;* 
;* INPUTS:
;*      LOCATION - A STRING OF THE LOCATION CASE REQUIRED (E.G. 'INPUT' FOR THE INPUT FOLDER)     
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      RESULT   - THE FULL PATH OF THE LOCATIONS PATH, OR IF NOT FOUND THEN 'ERROR' 
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*        21 MAR 2011 - C KENT    - DIMITRI-2 V1.0
;*        23 AUG 2011 - C KENT    - ADDED TOOL NAME VARIABLE
;*
;* VALIDATION HISTORY:
;*        14 APR 2011 - C KENT    - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                                  COMPILATION AND OPERATION       
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_LOCATION,LOCATION,VERBOSE=VERBOSE

;----------------------
; IDENTIFIY CURRENT DIRECTORY AND INPUT FOLDER

  CD, CURRENT=CURRENT_DIR
  POS = STRPOS(CURRENT_DIR,'DIMITRI_',/REVERSE_SEARCH)
  IF POS EQ -1 THEN BEGIN
    PRINT, 'ERROR, INPUT DIMITRI FOLDER NOT FOUND'
    RETURN,'ERROR'
  ENDIF
  
  DL = PATH_SEP();STRMID(CURRENT_DIR,POS-1,1)
  CENTRAL_FOLDER = STRING(STRMID(CURRENT_DIR,0,POS+11)+DL)
    
  CASE LOCATION OF
  
;----------------------
; FOLDERS
  
  'DL'            : RESULT = DL 
  'DIMITRI'       : RESULT = CENTRAL_FOLDER
  'INPUT'         : RESULT = CENTRAL_FOLDER+'Input'+DL
  'OUTPUT'        : RESULT = CENTRAL_FOLDER+'Output'+DL
  'AUX'           : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL
  'RSR'           : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'spectral_response'+DL
  'RSR_DIM'       : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'spectral_response'+DL+'DIMITRI_Sites'+dl  
  'RSR_USR'       : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'spectral_response'+DL+'USER_Sites'+dl
  'BIN'           : RESULT = CENTRAL_FOLDER+'Bin'+DL
  'DB_BACKUP'     : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DB_backup'+DL
  'SOURCE'        : RESULT = CENTRAL_FOLDER+'Source'+DL
  'BITMAPS'       : RESULT = CENTRAL_FOLDER+'Source'+DL+'bitmaps'+DL
  'PNG_IMAGES'    : RESULT = CENTRAL_FOLDER+'Source'+DL+'png'+DL

;----------------------
; FILES
  
  'AATSR_DRIFT'   : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'AATSR_VIS_DRIFT_V02-01.DAT'
  'MERIS_IM2004'  : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'MERIS_Irradiances_Model2004.txt'
  'CONFIG'        : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_CONFIGURATION.txt'
  'BAND_INDEX'    : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_Band_Centre_Index.txt'
  'BAND_NAME'     : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_Band_Names.txt'
  'DATABASE'      : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_DATABASE.CSV'
  'SENSOR_DATA'   : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_SENSOR_DATA.txt'
  'SITE_DATA'     : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_SITE_DATA.txt'
  'SITE_TYPES'    : RESULT = CENTRAL_FOLDER+'Bin'+DL+'DIMITRI_SITE_TYPES.txt'
  'TITLE_PNG'     : RESULT = CENTRAL_FOLDER+'Source'+DL+'png'+DL+'dimitri_title.png'
  'INGEST_PNG'    : RESULT = CENTRAL_FOLDER+'Source'+DL+'png'+DL+'ingest.png'
  'PROCESS_PNG'   : RESULT = CENTRAL_FOLDER+'Source'+DL+'png'+DL+'process.png'
  'VISU_PNG'      : RESULT = CENTRAL_FOLDER+'Source'+DL+'png'+DL+'visualise.png'
  'BRIGHT_LUT'    : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'CLOUD_SCREENING_Bright_Threshold_LUT.dat'
  'OZONE_TRANS'   : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'transmission'+dl+'Transmission_O3.txt'
  'WVAP_TRANS'    : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'transmission'+dl+'Transmission_H2O.txt'
  'GAS_TRANS'     : RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'transmission'+dl+'Transmission_O2_trace_gases.txt'
  'VGT_CORRECTION': RESULT = CENTRAL_FOLDER+'AUX_DATA'+DL+'VGT2_CNES_Earth_Sun_correction.txt'
  'SUM'           : RESULT = CENTRAL_FOLDER+'User_Manual.pdf'
  
;----------------------
; VALUES

  'TOOL'          : RESULT = 'DIMITRI V2.0'
    
  ELSE            : BEGIN
                      PRINT, 'ERROR, LOCATION CASE NOT FOUND'
                      RETURN,'ERROR'
                    END
  ENDCASE

;----------------------
; RETURN PATH FOUND

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'RETRIEVED LOCATION : ',RESULT
  RETURN, REsULT

END