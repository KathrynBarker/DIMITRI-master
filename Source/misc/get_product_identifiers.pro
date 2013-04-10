;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_PRODUCT_IDENTIFIERS       
;* 
;* PURPOSE:
;*      RETURNS AN ARRAY OF FILTERS FOR SEARCHING FOR DATA PRODUCTS
;* 
;* CALLING SEQUENCE:
;*      RES = GET_PRODUCT_IDENTIFIERS(SENSOR_ID)      
;* 
;* INPUTS:
;*      SENSOR_ID = A STRING CONTAINING THE NAME OF THE REQUIRED SENSOR PRODUCTS, 'ALL'RETURNS ALL FILTERS
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      SEARCH_FILTER  - AN ARRAY OF THE REQEUSTED SERAHC FILTERS
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      23 DEC 2010 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      23 DEC 2010 - C KENT   - WINDOWS 32-BIT MACHINE IDL 7.1: COMPILATION AND CALLING SUCCESSFUL 
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_PRODUCT_IDENTIFIERS,SEARCH_SENSOR,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'PRODUCT_ID: RETRIEVING PRODUCT FILTER FOR SENSOR - ',SEARCH_SENSOR

  CASE SEARCH_SENSOR OF
    'AATSR'       : SEARCH_FILTER = ['ATS_TOA_1*.N1']
    'ATSR2'       : SEARCH_FILTER = ['AT2_TOA_1*.E2']   
    'MERIS'       : SEARCH_FILTER = ['MER_RR__1*.N1'] 
    'MODISA'      : SEARCH_FILTER = ['MYD021KM.*.hdf']
    'PARASOL'     : SEARCH_FILTER = ['P3L1TBG*D*0']
    'VEGETATION'  : SEARCH_FILTER = ['*_LOG.TXT']
    'ALL'         : SEARCH_FILTER = ['ATS_TOA_1*.N1','AT2_TOA_1*.E2','MER_RR__1*.N1','MYD021KM.*.hdf','P3L1TBG*D*0','*_LOG.TXT'] 
    ELSE          : SEARCH_FILTER = ['ERROR.ERROR']
  ENDCASE 

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'PRODUCT_ID: RETURNING PRODUCT FILTER ARRAY'
  RETURN,SEARCH_FILTER

END

