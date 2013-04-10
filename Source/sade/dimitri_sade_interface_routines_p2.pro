PRO DIMITRI_SADE_INTERFACE_ROUTINES_P2

;0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;
; SECTION 2: VGT SIMULATION
;
;0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
;0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

;----------------------------
; USAGE
;
; UPDATE THE PARAMETERS BELOW FOR YOUR SPECIFIC FOLDERS AND CRITERIA THEN RUN THE PROGRAM (NEED TO RESTORE DIMITRI_V2.SAV)
; ALL NOMINAL DIMITRI OUTPUTS WILL BE PLACED IN THE DEFINED "MFOLDER"

;----------------------------
; SET UP PARAMETERS - TO BE CHANGED
  
  MAIN_DIR          = GET_DIMITRI_LOCATION('DIMITRI'); FULL PATH OF THE MAIN DIMITRI DIRECTORY
  print,'Main Dir___: ',MAIN_DIR
  MFOLDER           = filepath('',root_dir = MAIN_DIR, subdir=['Output','VGT_TEST_2']) ; FULL PATH OF THE OUTPUT FOLDER WITH MERIS AS REFERENCE
  AFOLDER           = filepath('',root_dir = MAIN_DIR, subdir=['Output','VGT_TEST_2']) ; FULL PATH OF THE OUTPUT FOLDER WITH AATSR AS REFERENCE
  ;REGION            = 'Niger2'                           
  REGION            = 'DomeC'                           
  VZA_MIN           = 0.                                  ; VZA MIN ANGLE (DEGREES)
  VZA_MAX           = 90.                                 ; VZA MAX ANGLE (DEGREES)
  VAA_MIN           = 0.                                  ; VAA MIN ANGLE (DEGREES)
  VAA_MAX           = 360.                                ; VAA MAX ANGLE (DEGREES)
  SZA_MIN           = 0.                                  ; SZA MIN ANGLE (DEGREES)
  SZA_MAX           = 90.                                 ; SZA MAX ANGLE (DEGREES)
  SAA_MIN           = 0.                                  ; SAA MIN ANGLE (DEGREES)
  SAA_MAX           = 360.                                ; SAA MAX ANGLE (DEGREES)  
;  SADE_DIR          = '/mnt/Projects/MEREMSII/WG_Reference_Dataset_2/distributable_files/' ;change this to the location of your sade files (note, region subdirectory in filepath below
  CASE STRUPCASE(!VERSION.OS_FAMILY) OF 
  'WINDOWS': SADE_DIR = 'R:\MEREMSII\WG_Reference_Dataset\distributable_files\'
  'UNIX':    SADE_DIR = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/distributable_files/'
  ENDCASE
  NO_PLOTS          = 1 ; 1 MEANS NO BRDF PLOTS (WHICH TAKE AWHILE) WILL BE GENERATED
  ;BRDF_BIN          = 5 ; BINNING PERIOD FOR BRDF MODEL IN DAYS
  ;BRDF_LIM          = 3 ; MINIMUM NUMBER OF ACQUISITIONS FOR A BRDF MODEL
  BRDF_BIN          = 30 ; BINNING PERIOD FOR BRDF MODEL IN DAYS ; - Andrei, copied from Francoise's example
  BRDF_LIM          = 10 ; MINIMUM NUMBER OF ACQUISITIONS FOR A BRDF MODEL ; - Andrei, copied from Francoise's example

;----------------------------
; NO NEED TO CHANGE THESE ONES

  SENSOR1S          = ['MERIS','AATSR']  ; no need to change        
  PROC_VER1S        = ['2nd_Reprocessing','2nd_Reprocessing'] ; no need to change     
  VGT_PROC          = 'Calibration_1' ; no need to change
  VGT_SADE          = FILEPATH(REGION+'_VEGETATION_Calibration_1.SADE',ROOT_DIR=SADE_DIR,SUBDIR=[REGION]);no need to change
  FOLS              = [MFOLDER,AFOLDER]

  print,'VGT_SADE: ',VGT_SADE
  print,'REGION: ',REGION
  print,'MFOLDER: ',MFOLDER
 
  ;stop 
  FOR IVOS=0,1 DO BEGIN
    SENSOR1=SENSOR1S[IVOS]
    PROC_VER1=PROC_VER1S[IVOS]
    OFOLDER = FOLS[IVOS]  
  
;----------------------------
; BRDF COMPUTATION
    RES = DIMITRI_INTERFACE_ROUJEAN(OFOLDER,REGION,SENSOR1,PROC_VER1,$
                                    BRDF_BIN=BRDF_BIN,BRDF_LIM=BRDF_LIM,NO_PLOTS=NO_PLOTS)
  
    IF RES[0] NE 1 THEN BEGIN
      PRINT, '******* ERROR, A PROBLEM OCCURED DURING BRDF COMPUTATION ********'
     ; RETURN
    ENDIF

  ENDFOR ;END OF LOOP ON BRDF FOR MERIS AND AATSR

;----------------------------
; VGT SIMULATION

  RES = VGT_SIMULATION(REGION,MFOLDER,PROC_VER1S[0],AFOLDER,PROC_VER1S[1],VGT_PROC,$
                       99.,1.0,BRDF_BIN,$
                       VZA_MIN,VZA_MAX,VAA_MIN,VAA_MAX,SZA_MIN,SZA_MAX,SAA_MIN,SAA_MAX,$                          
                       VERBOSE=VERBOSE,VGT_SADE=VGT_SADE)

  IF RES[0] NE 1 THEN BEGIN
    PRINT, '******* ERROR, A PROBLEM OCCURED DURING VGT SIMULATION ********'
    RETURN
  ENDIF
  
END
  