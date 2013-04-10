;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      DIMITRI_POLYNOMIAL_FIT_FUNCTION       
;* 
;* PURPOSE:
;*      THIS PROGRAM IS UTILISED DURING THE POLYNOMIAL FITTING OF THE BIAS BETWEEN TWO 
;*      SENSORS. IT IS CALLED BY CRAIG B. MARKWARDT'S MPCURVEFIT.PRO
;* 
;* CALLING SEQUENCE:
;*      DIMITRI_POLYNOMIAL_FIT_FUNCTION,X,P,YMOD      
;*
;* INPUTS:
;*      X       - AN ARRAY OF VALUES TO BE TREATED AS THE X VARIABLE
;*      P       - AN ARRAY OF COEFICIENTS USED TO COMPUTE X INTO YMOD
;*      YMOD    - A NULL VALUE (E.G. 0), WHICH IS REDEFINED WHEN CALLED
;*
;* KEYWORDS:
;*      VERBOSE - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      NONE
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      08 FEB 2011 - C KENT    - DIMITRI-2 V1.0
;*
;* VALIDATION HISTORY:
;*      08 FEB 2011 - C KENT    - WINDOWS 32-BIT MACHINE IDL 7.1/IDL 8.0: NOMINAL
;*      13 APR 2011 - C KENT    - LINUX 64-BIT MACHINE IDL 8.0: NOMINAL 
;*
;**************************************************************************************
;**************************************************************************************

PRO DIMITRI_POLYNOMIAL_FIT_FUNCTION,X,P,YMOD,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'POLYNOMIAL FITTING FUNCTION: GENERATING NEW Y VALUES'
  YMOD = P[0]+(P[1]*X)+(P[2]*(X^2)) 

END

