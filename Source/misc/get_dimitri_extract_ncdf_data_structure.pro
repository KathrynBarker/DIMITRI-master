;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_EXTRACT_NCDF_DATA_STRUCTURE   
;* 
;* PURPOSE:
;*      THIS FUNCTION RETURNS THE STRUCTURE FOR DATA TO BE OUTPUT INTO THE NETCDF FORMAT
;*
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_EXTRACT_NCDF_DATA_STRUCTURE(NPROD,NBANDS,NVIEWS)
;* 
;* INPUTS:
;*      NPROD     - THE NUMBER OF PRODUCTS  
;*      NBANDS    - THE NUMBER OF BANDS
;*      NVIEWS    - THE NUMBER OF PRODUCT VIEWS
;*
;* KEYWORDS:
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      NC_DATA   - A STRUCTURE OF THE DATA ARRAYS FOR OUTPUT
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      23 AUG 2011 - C KENT   - DIMITRI-2 V1.0
;*      30 AUG 2011 - C KENT   - ADDED MANUAL CLOUD SCREENING OUTPUT TO NETCDF
;*      12 SEP 2011 - C KENT   - ADDED NVIEW DEPENDENCY
;*      09 MAR 2012 - C KENT   - ADDED ROI_COVER
;*
;* VALIDATION HISTORY:
;*      
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_EXTRACT_NCDF_DATA_STRUCTURE,NPROD,NBANDS,NVIEWS,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_EXTRACT_NCDF_DATA_STRUCTURE: DEFINING STRUCTURE'
  NULL_STR = 'NULL'
  BAD_VAL = -999.

  NC_DATA   = {                                    $
              ATT_FNAME   : NULL_STR              ,$
              ATT_TOOL    : NULL_STR              ,$
              ATT_CTIME   : NULL_STR              ,$
              ATT_MTIME   : NULL_STR              ,$
              ATT_SENSOR  : NULL_STR              ,$
              ATT_PROCV   : NULL_STR              ,$
              ATT_PRES    : NULL_STR              ,$
              ATT_NBANDS  : NULL_STR              ,$
              ATT_NDIRS   : NULL_STR              ,$
              ATT_SITEN   : NULL_STR              ,$
              ATT_SITEC   : NULL_STR              ,$
              ATT_SITET   : NULL_STR              ,$
              VAR_PNAME   : STRARR(NPROD)+NULL_STR        ,$
              VAR_PTIME   : STRARR(NPROD)+NULL_STR        ,$
              VAR_DTIME   : DBLARR(NPROD)+BAD_VAL         ,$
              VAR_ROI     : INTARR(NPROD)+BAD_VAL         ,$
              VAR_PIX     : REFORM(FLTARR(NBANDS,NPROD,NVIEWS)+BAD_VAL,NBANDS,NPROD,NVIEWS)  ,$
              VAR_RHOMU   : REFORM(FLTARR(NBANDS,NPROD,NVIEWS)+BAD_VAL,NBANDS,NPROD,NVIEWS)  ,$
              VAR_RHOSD   : REFORM(FLTARR(NBANDS,NPROD,NVIEWS)+BAD_VAL,NBANDS,NPROD,NVIEWS)  ,$
              VAR_CLOUD_AUT   : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_CLOUD_MAN   : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_VZA     : REFORM(FLTARR(NVIEWS,NPROD)+BAD_VAL,NVIEWS,NPROD)         ,$
              VAR_VAA     : REFORM(FLTARR(NVIEWS,NPROD)+BAD_VAL,NVIEWS,NPROD)         ,$
              VAR_SZA     : REFORM(FLTARR(NVIEWS,NPROD)+BAD_VAL,NVIEWS,NPROD)         ,$
              VAR_SAA     : REFORM(FLTARR(NVIEWS,NPROD)+BAD_VAL,NVIEWS,NPROD)         ,$
              VAR_OZONEMU : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_OZONESD : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_WVAPMU  : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_WVAPSD  : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_PRESSMU : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_PRESSSD : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_RHUMMU  : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_RHUMSD  : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_ZONALMU : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_ZONALSD : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_MERIDMU : FLTARR(NPROD)+BAD_VAL         ,$
              VAR_MERIDSD : FLTARR(NPROD)+BAD_VAL          $
              }

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_EXTRACT_NCDF_DATA_STRUCTURE: RETURNING STRUCTURE'
  RETURN,NC_DATA

END