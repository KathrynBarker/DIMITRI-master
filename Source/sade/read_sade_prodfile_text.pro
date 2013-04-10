;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      READ_SADE_PRODFILE_TEXT   
;* 
;* PURPOSE:
;*      READS THE TEXT FILES CONTAINING PRODUCTS AND QUICKLOOKS 
;*      TO BE REMOVED FROM THE SADE DATASET
;* 
;* CALLING SEQUENCE:
;*      RES = READ_SADE_PRODFILE_TEXT(PRODFILE)
;* 
;* INPUTS:
;*      PRODFILE  - THE FULL PATH OF THE PRODUCT LIST FILE   
;*
;* KEYWORDS:
;*
;* OUTPUTS:
;*      PRODDATA  - THE LIST OF PRODUCTS FOR REMOVAL   
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      16 DEC 2011 - C KENT  - INITIAL DIMITRI VERSION
;*
;* VALIDATION HISTORY:
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION READ_SADE_PRODFILE_TEXT,PRODFILE

  TEMPLATE=CREATE_STRUCT('VERSION', 1.0,$
                        'DATASTART',0,$
                        'DELIMITER', ' ',$  ;IS SPACE DELIMITED
                        'MISSINGVALUE',-999,$
                        'COMMENTSYMBOL','"',$
                        'FIELDCOUNT',[1],$
                        'FIELDTYPES', [7],$
                        'FIELDNAMES', ['BADPROD'],$
                        'FIELDLOCATIONS',[0],$
                        'FIELDGROUPS',[1])
  
  PRODDATA = READ_ASCII(PRODFILE,TEMPLATE=TEMPLATE)
  RETURN,PRODDATA

END