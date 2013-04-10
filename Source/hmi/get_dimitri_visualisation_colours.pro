;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_VISUALISATION_COLOURS       
;* 
;* PURPOSE:
;*      RETURNS AN ARRAY OF COLOURS UTILISED BY THE DIMITRI VISUALISATION MODULE
;* 
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_VISUALISATION_COLOURS(N_CONFIGS)     
;* 
;* INPUTS:
;*      N_CONFIGS - THE NUMBER OF COLOURS TO BE RETURNED (MAX = 20)
;*
;* KEYWORDS:
;*      VERBOSE  - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      COLOURS  - A BYTE ARRAY CONTAINING THE RGB INFORMATION FOR THE REQUESTED 
;*                 NUMBER OF COLOURS
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      08 FEB 2011 - C KENT   - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      08 FEB 2011 - C KENT   - WINDOWS 32-BIT MACHINE IDL 7.1: NOMINAL COMPILATION 
;*      14 APR 2011 - C KENT   - WINDOWS 32-BIT IDL 7.1 AND LINUX 64-BIT IDL 8.0 NOMINAL
;*                               COMPILATION AND OPERATION
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_VISUALISATION_COLOURS,N_CONFIGS,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_COLOURS: NUMBER OF COLOURS TO BE RETRIEVED = ',N_CONFIGS 
  N       = N_CONFIGS<20
;  COLOURS = [$
;          !COLOR.RED,$
;          !COLOR.BLUE,$
;          !COLOR.GREEN,$
;          !COLOR.PURPLE,$
;          !COLOR.NAVY,$
;          !COLOR.ORANGE,$
;          !COLOR.PLUM,$
;          !COLOR.GOLD,$
;          !COLOR.DEEP_PINK,$
;          !COLOR.DARK_RED,$
;          !COLOR.DARK_MAGENTA,$
;          !COLOR.DARK_GREY,$
;          !COLOR.BROWN,$
;          !COLOR.BEIGE,$
;          !COLOR.CYAN,$
;          !COLOR.FOREST_GREEN,$
;          !COLOR.INDIAN_RED,$
;          !COLOR.BLACK,$
;          !COLOR.LAVENDER,$
;          !COLOR.OLIVE $
;          ]

  COLOURS = [$
              255,0,0     ,$
              0,0,255     ,$
              0,255,0     ,$
              127,0,127   ,$
              0,0,128     ,$
              255,165,0   ,$
              221,160,221 ,$
              255,215,0   ,$
              255,20,147  ,$
              139,0,0     ,$
              139,0,139   ,$
              169,169,169 ,$
              165,42,42   ,$
              245,245,220 ,$
              0,255,255   ,$
              34,139,34   ,$
              205,92,92   ,$
              0,0,0       ,$
              230,230,250 ,$
              128,128,0   ]

 COLOURS = REFORM(COLOURS,3,20)
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'DIMITRI_VISU_COLOURS: RETURNING BYTE ARRAY OF COLOURS'
  RETURN,COLOURS[*,0:N-1]
END

