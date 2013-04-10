PRO PLOT_DIMITRI_DOUBLETS,OUTPUT_FOLDER,DIMITRI_BAND,Region,DB_REF_SENSOR,DB_REF_PROC_VERSION

;-----------------------------------------
; CHECK OFOLDER EXISTS 
  
  RES = FILE_INFO(OUTPUT_FOLDER)
  IF RES.EXISTS EQ 0 THEN BEGIN
    PRINT,"PLOT_DIMITRI_DOUBLETS: OUTPUT FOLDER DOESN'T EXIST"
    RETURN,-1
  ENDIF
  
  RES = STRSPLIT(OFOLDER,'\',/EXTRACT)
  IF N_ELEMENTS(RES) EQ 1 THEN DL = '/' ELSE DL = '\' 

; FIND ALL CORRESPONDING DOUBLET EXTRACTION FILES 
  str1 = 'ED_'+region+'_'+DB_REF_SENSOR+'_'+DB_REF_PROC_VERSION+'*.dat'
  str2 = 'ED_'+region+'_*'+DB_REF_SENSOR+'_'+DB_REF_PROC_VERSION+'.dat'

  RES = FILE_SEARCH(ed_folder,str1)
  res2 = FILE_SEARCH(ed_folder,str2)
  if res[0] eq '' or res2[0] eq '' then return,-1
  if n_elements(res) ne n_elements(res2) then return,-1

;get sensor index correcponding to dimitri index

;start creating arrays
  tmp_date= 0.0
  tmp_vza = 0.0
  tmp_vaa = 0.0
  tmp_sza = 0.0
  tmp_saa = 0.0
  tmp_ref = 0.0

; get time series of reference sensor
  for i=0,n_elements(res)-1 do begin
    restore,res[i]
    tmp_date= [tmp_date,ED_SENSOR1_SENSOR2[0,*]]
    tmp_vza = [tmp_date,ED_SENSOR1_SENSOR2[1,*]]
    tmp_vaa = [tmp_date,ED_SENSOR1_SENSOR2[2,*]]
    tmp_sza = [tmp_date,ED_SENSOR1_SENSOR2[3,*]]
    tmp_saa = [tmp_date,ED_SENSOR1_SENSOR2[4,*]]
    tmp_ref = [tmp_date,ED_SENSOR1_SENSOR2[5+sensor_index,*]]
  endfor
  
 ;sort out arrays
 temp = n_elements(tmp_date)
 tmp_date=tmp_date[1:temp-1]
 tmp_vza =tmp_vza[1:temp-1]
 tmp_vaa =tmp_vaa[1:temp-1]
 tmp_sza =tmp_sza[1:temp-1]
 tmp_saa =tmp_saa[1:temp-1]
 tmp_ref =tmp_ref[1:temp-1]
 
 temp = UNIQ(tmp_date, SORT(tmp_date))
 tmp_date=tmp_date[temp]
 tmp_vza =tmp_vza[temp]
 tmp_vaa =tmp_vaa[temp]
 tmp_sza =tmp_sza[temp]
 tmp_saa =tmp_saa[temp]
 tmp_ref =tmp_ref[temp]
 n_dates = n_elements(tmp_date)
 
 
   ;get cal sensors and proc versions
  sens_ver = strarr(n_elements(res2)+1)
  sens_ver[0] = string(DB_REF_SENSOR+'_'+DB_REF_PROC_VERSION)
    
  ;define array to hold all data (ndates in reference sensor,n_cal sensors + 1,2)
  all_data = make_array(n_dates,n_elements(res2)+1,6)
  
  all_data[*,0,0] = tmp_date
  all_data[*,0,1] = tmp_vza
  all_data[*,0,2] = tmp_vaa
  all_data[*,0,3] = tmp_sza
  all_data[*,0,4] = tmp_saa
  all_data[*,0,5] = tmp_ref
  
  
  for i=0,n_elements(res2)-1 do begin
  temp = string(dl+'_')
  temp = strsplit(res2[i],temp,/extract)
  tmp = n_elements(temp)
  sens_ver[i] = string(temp[tmp-4]+'_'+temp[tmp-3])
  restore,res2[i]

  ;get idx relating to dimitri band
  idx=0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  tt = n_elements(ED_SENSOR2_SENSOR1[0,*])
  all_data[0:tt-1,i+1,0] = ED_SENSOR2_SENSOR1[0,*]
  all_data[0:tt-1,i+1,1] = ED_SENSOR2_SENSOR1[1,*]
  all_data[0:tt-1,i+1,2] = ED_SENSOR2_SENSOR1[2,*]
  all_data[0:tt-1,i+1,3] = ED_SENSOR2_SENSOR1[3,*]
  all_data[0:tt-1,i+1,4] = ED_SENSOR2_SENSOR1[4,*]
  all_data[0:tt-1,i+1,5] = ED_SENSOR2_SENSOR1[5+idx,*]
  endfor

;create an object array for all sensor configurations

  obj_test = objarr(5,n_elements(res2)+1,2)
  plot_type = intarr(5);0-3 for angles, 4 for reflectance
  
  ;get colours for number of sensors
  sensor_colours = bytarr(3*n_elements(res2)+1)
  sensor_colours = reform(sensor_colours,3,n_elements(res2)+1)

;SET UP PLOT PARAMETERS
  xtmp = min(all_data[*,0,0],max=xtmp2)
  RSR_XRANGE  = [xtmp,xtmp2]
  ytmp = min(all_data[*,*,5],max=ytmp2)
  ytmp = ytmp>0.0<100.0
  ytmp2= ytmp2>0.0<100.0
;  RSR_YRANGE  = [tmp,tmp2]
  XMAJTICKS   = (1+(xtmp2-xtmp)*0.05)<11
  YMAJTICKS   = 1+(ytmp2-ytmp)

;need a y range of 2 columns and 5 lines
RSR_yrange = fltarr(2,5)
for i=0,4 do begin
ytmp = min(all_data[*,*,i+1],max=ytmp2)
  RSR_yrange[0,i] = ytmp>0.0<100.0
  RSR_yrange[1,i]= ytmp2>0.0<100.0
endif

;------------------------------------ 
; CREATE THE PALETTE OBJECT
  
  COLORTABLE  = 39
  RSR_PALETTE = OBJ_NEW('IDLGRPALETTE')
  RSR_PALETTE->LOADCT, COLORTABLE


xtitle = OBJ_NEW('IDLGRTEXT',"Date",RECOMPUTE_DIMENSION=1)
ytitles = objarr(5)
tt = ['vza','vaa','sza','vza','reflectance']
for i=0,4 do ytitles[i] = OBJ_NEW('IDLGRTEXT',tt[i],RECOMPUTE_DIMENSION=1)

;------------------------------------ 
; CREATE THE AXIS OBJECTS

  RSR_XAXIS = OBJ_NEW('IDLGRAXIS', 0, TICKLEN=0.025, MAJOR=XMAJTICKS, TITLE=xtitle, $
                      RANGE=RSR_XRANGE, /EXACT, XCOORD_CONV=NORM_COORD(RSR_XRANGE))
  RSR_YAXIS = OBJ_NEW('IDLGRAXIS', 1, TICKLEN=0.025, MINOR=4, TITLE='unselected', $
                      RANGE=[0.0,1.0], /EXACT, YCOORD_CONV=NORM_COORD([0.0,1.0]))
  RSR_LEGEND = OBJ_NEW('IDLGRLEGEND',/SHOW_OUTLINE,/HIDE,BORDER_GAP=0.2)

;------------------------------------  
 ; CREATE THE PLOT MODEL
 
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: CREATING THE PLOT AND LEGEND MODELS'
  RSR_MODEL = OBJ_NEW('IDLGRMODEL')
  RSR_MODEL->ADD,RSR_XAXIS
  RSR_MODEL->ADD,RSR_YAXIS
  RSR_LEGENDMODEL = OBJ_NEW('IDLGRMODEL')
  RSR_LEGENDMODEL->ADD,RSR_LEGEND

;------------------------------------ 
; CREATE THE PLOT VIEW

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: CREATING THE RSR_VIEW'
  RSR_VIEW = OBJ_NEW('IDLGRVIEW',/DOUBLE)
  RSR_VIEW->ADD,RSR_MODEL
  RSR_VIEW->ADD,RSR_LEGENDMODEL
  RSR_VIEW->SETPROPERTY, VIEWPLANE_RECT = [-0.1, -0.1, 1.2, 1.2]

;--------------------------------------------------------------------------------------------------------------------
;------------------------------------ 
; GET THE SCREEN DIMENSIONS

  DIMS  = GET_SCREEN_SIZE()
  XSIZE = 700
  YSIZE = 450
  XLOC  = (DIMS[0]/2)-(XSIZE/2)
  YLOC  = (DIMS[1]/2)-(YSIZE/2)

;------------------------------------ 
; DEFINE THE BASE WIDGET FOR THE PLOT

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: DEFINING THE WIDGET AND BUTTONS'
  RSR_WD_TLB  = WIDGET_BASE(TITLE='DIMITRI: doublet extraction visualise',MBAR=MENUBASE,TLB_SIZE_EVENTS=1,$
                            COLUMN=1, BASE_ALIGN_CENTER=1,XOFFSET=XLOC, YOFFSET=YLOC)
  RSR_WD_DRAW = WIDGET_DRAW(RSR_WD_TLB, XSIZE=XSIZE, YSIZE=YSIZE, GRAPHICS_LEVEL=2, RETAIN=2)

;;------------------------------------ 
;; CREATE THE FILE MENU AND BUTTONS
;
;  RSR_WD_FILE = WIDGET_BUTTON(MENUBASE,     VALUE='File'      ,/MENU)
;  RSR_WD_IMPT = WIDGET_BUTTON(RSR_WD_FILE,  VALUE='Import'    ,UVALUE='IMPORT',EVENT_PRO='RSR_OBJECT_IMPORT')
;  RSR_WD_EXPT = WIDGET_BUTTON(RSR_WD_FILE,  VALUE='Save as...',/MENU)
;  RSR_WD_OUPT = WIDGET_BUTTON(RSR_WD_EXPT,  VALUE='JPG'       ,UVALUE='JPG'   ,EVENT_PRO='RSR_OBJECT_EXPORT')
;  RSR_WD_OUPT = WIDGET_BUTTON(RSR_WD_EXPT,  VALUE='PNG'       ,UVALUE='PNG'   ,EVENT_PRO='RSR_OBJECT_EXPORT')
;  RSR_WD_OUPT = WIDGET_BUTTON(RSR_WD_EXPT,  VALUE='CSV'       ,UVALUE='CSV'   ,EVENT_PRO='RSR_OBJECT_EXPORT')
;  RSR_WD_EXIT = WIDGET_BUTTON(RSR_WD_FILE, /SEPARATOR         ,VALUE ='Exit'  ,EVENT_PRO='RSR_OBJECT_EXIT')
;
;;------------------------------------ 
;; CREATE THE OVERLAY MENU AND BUTTONS
;
;  RSR_WD_OVLY = WIDGET_BUTTON(MENUBASE,     VALUE='Overlay' ,/MENU)
;  RSR_WD_OPTS = WIDGET_BUTTON(RSR_WD_OVLY,  VALUE='Options' ,/MENU)
;  RSR_WD_REFS = WIDGET_BUTTON(RSR_WD_OPTS,  VALUE='Legend'  ,UVALUE='LEGEND', EVENT_PRO='RSR_OBJECT_OPTION')
;  RSR_WD_REFS = WIDGET_BUTTON(RSR_WD_OPTS,  VALUE='Reset'   ,UVALUE='RESET' , EVENT_PRO='RSR_OBJECT_OPTION')
;
;;------------------------------------ 
;; LOOP OVER EACH SENSOR AND CREATE BUTTON
;  
;  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: STARTING LOOP TO DEFINE BUTTONS FOR EACH SENSOR'
;  FOR RSR_SENS=0,NUM_SENSORS-1 DO BEGIN
;    RSR_WD_SENS = WIDGET_BUTTON(RSR_WD_OVLY, VALUE=SENSOR_ID[RSR_SENS],$
;                                UVALUE=SENSOR_ID[RSR_SENS], EVENT_PRO='RSR_OBJECT_OPTION')
;  ENDFOR

;------------------------------------  
; REALIZE THE WIDGET

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: REALISING THE WIDGET'
  WIDGET_CONTROL, RSR_WD_TLB, /REALIZE
  WIDGET_CONTROL, RSR_WD_DRAW, GET_VALUE=RSR_WINDOW
 
;------------------------------------  
; CREATE THE BLANK PLOT AND MOVE THE LEGEND
 
  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: ADDING THE BLANK PLOT AND MOVING THE LEGEND'
  RSR_WINDOW->DRAW, RSR_VIEW
  DIMS = RSR_LEGEND->COMPUTEDIMENSIONS(RSR_WINDOW) 
  RSR_LEGENDMODEL->TRANSLATE, .92, .8, 0 
  RSR_WINDOW->SETPROPERTY, PALETTE=RSR_PALETTE
  RSR_WINDOW->DRAW, RSR_VIEW

;------------------------------------  
; DEFINE THE INFO STRUCTURE TO CONTAIN 
; ALL DATA AND OBJECTS

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'RSR PLOT MODULE: DEFINING SUPER STRUCTURE TO CONTAIN ALL DATA'
  RSR_INFO = {RSR_PALETTE:RSR_PALETTE, $
              RSR_WINDOW:RSR_WINDOW, $
              RSR_VIEW:RSR_VIEW, $
              RSR_LEGEND:RSR_LEGEND, $
              RSR_LEGENDMODEL:RSR_LEGENDMODEL,$
              RSR_XRANGE:RSR_XRANGE,$
              RSR_YRANGE:RSR_YRANGE,$
              RSR_YTITLE:RSR_YTITLE,$
              RSR_XTITLE:RSR_XTITLE,$
              RSR_XAXIS:RSR_XAXIS,$
              RSR_YAXIS:RSR_YAXIS,$
              RSR_DATA:RSR_DATA,$
              RSR_OBJ:RSR_OBJ,$
              WAVELENGTHS:WAVELENGTHS, $
              SENSOR_COLOURS:SENSOR_COLOURS,$
              SENSOR_ID:SENSOR_ID, $
              SENSOR_BANDS:SENSOR_BANDS, $
              SENS_ON:SENS_ON, $
              USR_DATA:USR_DATA,$
              USER_DATA_ON:[0],$
              USER_COLOUR:USER_COLOUR,$
              USER_DATA_NAME:'', $
              USERXDATA:PTR_NEW(0.0),$
              USERYDATA:PTR_NEW(0.0)$
             }

  WIDGET_CONTROL,RSR_WD_TLB,SET_UVALUE=RSR_INFO,/NO_COPY
  XMANAGER,'RSR_OBJECT', RSR_WD_TLB, GROUP_LEADER=GROUP,/NO_BLOCK

END