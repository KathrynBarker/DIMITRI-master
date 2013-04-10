;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      CREATE_NEW_DIMITRI_TAR            
;* 
;* PURPOSE:
;*      CREATES A NEW DIMITRI TAR DISTRIBUTION - ONLY FOR USE ON KEPLER
;* 
;* CALLING SEQUENCE:
;*      CREATE_NEW_DIMITRI_TAR      
;* 
;* INPUTS:
;*      
;*
;* KEYWORDS:
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      13 JUN 2012 - C KENT   - DIMITRI-2 V1.0
;*      03 Aug 2012 - K Barker   UPDATE: User Manual added to .tar
;*
;* VALIDATION HISTORY:
;*
;**************************************************************************************
;**************************************************************************************

PRO CREATE_NEW_DIMITRI_TAR

; DEFINE INPUT AND OUTPUT FOLDER LOCATIONS
  
  IFOLDER = '/mnt/Projects/MEREMSII/DIMITRI/20120305/'
  OFOLDER = '/mnt/Projects/MEREMSII/DIMITRI/new_dist/'; update this location to where you want the new distribution to be 
  DIMITRI = 'DIMITRI_2.0'
  DL = PATH_SEP()
  STIME = SYSTIME()

; CREATE NEW DIMITRI FOLDER

  IF ~FILE_TEST(OFOLDER)         THEN FILE_MKDIR,OFOLDER
  IF ~FILE_TEST(OFOLDER+DIMITRI) THEN FILE_MKDIR,OFOLDER+DIMITRI

; COPY BIN, AUX DATA, OUTPUT FOLDERS, DIMITRI SAV + User Manual

  SPAWN, 'cp -rf '+IFOLDER+DIMITRI+DL+'User_Manual.pdf '+OFOLDER+DIMITRI+DL
  SPAWN, 'cp -rf '+IFOLDER+DIMITRI+DL+'AUX_DATA '+OFOLDER+DIMITRI+DL
  SPAWN, 'cp -rf '+IFOLDER+DIMITRI+DL+'Bin '+OFOLDER+DIMITRI+DL
  SPAWN, 'cp -rf '+IFOLDER+DIMITRI+DL+'DIMITRI_V2.sav '+OFOLDER+DIMITRI+DL
  IF ~FILE_TEST(OFOLDER+DIMITRI+DL+'Output') THEN FILE_MKDIR,OFOLDER+DIMITRI+DL+'Output'  
  IF ~FILE_TEST(OFOLDER+DIMITRI+DL+'Input')  THEN FILE_MKDIR,OFOLDER+DIMITRI+DL+'Input' 
  SPAWN, 'cp -rf '+IFOLDER+DIMITRI+DL+'Source '+OFOLDER+DIMITRI+DL
  FILE_DELETE,OFOLDER+DIMITRI+DL+'Source'+DL+'.git',/RECURSIVE
  FILE_DELETE,OFOLDER+DIMITRI+DL+'Source'+DL+'validation',/RECURSIVE  

  SITES     = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
  SENSORS   = ['AATSR','ATSR2','MERIS','MERIS','MODISA','PARASOL','VEGETATION']
  PROC_VERS = ['2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5','Calibration_1','Calibration_1']
  YEARS     = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012']

  FOR I=0L,N_ELEMENTS(SITES)-1 DO BEGIN
   
    INF = IFOLDER+DIMITRI+DL+'Input'+DL
    ONF = OFOLDER+DIMITRI+DL+'Input'+DL
    SF = ONF+'Site_'+SITES[I]
    FILE_MKDIR,SF
    
    FOR J=0L,N_ELEMENTS(SENSORS)-1 DO BEGIN
 
      TF = SF+DL+SENSORS[J]
      FILE_MKDIR,TF
      PF = TF+DL+'Proc_'+PROC_VERS[J]
      FILE_MKDIR,PF
      OPF = INF+'Site_'+SITES[I]+DL+SENSORS[J]+DL+'Proc_'+PROC_VERS[J]
      RES = FILE_SEARCH(OPF,STRING('*'+SENSORS[J]+'_*'))
      IF RES[0] NE '' THEN FOR M=0L,N_ELEMENTS(RES)-1 DO FILE_COPY,RES[M],PF,/OVERWRITE
       
      FOR K = 0L,N_ELEMENTS(YEARS)-1 DO BEGIN
 
        YF = PF+DL+YEARS[K]
        FILE_MKDIR,YF
        OYF = OPF+DL+YEARS[K]
        IF SENSORS[J] NE 'VEGETATION' THEN BEGIN
          
          RES = FILE_SEARCH(OYF,'*.jpg')
          IF RES[0] NE '' THEN FOR M=0L,N_ELEMENTS(RES)-1 DO FILE_COPY,RES[M],YF 
        
        ENDIF ELSE BEGIN
          
          IF FILE_TEST(OYF) EQ 1 THEN BEGIN
          
            RES = FILE_SEARCH(OYF,'*.jpg')
            IF RES[0] NE '' THEN BEGIN
              
              FOR M=0,N_ELEMENTS(RES)-1 DO BEGIN
                
                OFOLD = YF+STRMID(RES[M],STRLEN(YF),STRLEN(RES[M])-STRLEN(YF))
                FILE_MKDIR,STRMID(OFOLD,0,STRLEN(OFOLD)-18)
                FILE_COPY,RES[M],OFOLD 
                
              ENDFOR
              
            ENDIF
          ENDIF
        ENDELSE
      ENDFOR
    ENDFOR
  ENDFOR

; TAR IT INTO A DISTRIBUTABLE PACKAGE
  
  CD,CURRENT=CDIR
  CD,OFOLDER
  SPAWN,'tar -zcvf DIMITRI_V2.tar.gz '+DIMITRI+DL
  CD,CDIR

  PRINT
  PRINT,'**********************************'
  PRINT,'*   COMPLETED DIMITRI TAR        *
  PRINT,'*   S: '+STIME+'  *
  PRINT,'*   E: '+SYSTIME()+'  *
  PRINT,'**********************************'
    
END