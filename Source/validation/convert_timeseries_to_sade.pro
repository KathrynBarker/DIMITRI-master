PRO CONVERT_TIMESERIES_TO_SADE,SENSOR,proc_ver,SENSOR_DATA,NUMPIXS,BANDS_INDEX,SITE,prodnames,PFLAG

;NEED INPUT = SENSOR, BANDS INDEX, NUM DIRECTIONS,SITENAME AND ICOORDS
;INPUT TIME SERIES WILL BE OF FORM
;[PARAMS,OBSERVATIONS]
;------------------------------
ft = get_dimitri_location('SITE_DATA')
icoords = get_site_coordinates(SITE,ft)

;-----------------------------
; DEFINE OUTPUT FILE - MAKE SURE YOU ARE IN CORRECT CD

  rdifol = get_dimitri_location('INPUT')
  rdofol = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/'
  dl = PATH_SEP()
  OUTPUTFILE = rdofol+SITE+dl+site+'_'+SENSOR+'_'+proc_ver+'.SADE'
  OPENW,OUTF,OUTPUTFILE,/GET_LUN

  jpgfol = rdofol+SITE+dl+sensor
  if file_test(jpgfol) eq 0 then file_mkdir,jpgfol

;------------------------------
; GET SITE LAT AND LON FROM ICOORDS 

  SITE_LAT = MEAN(ICOORDS[0:1])
  SITE_LON = MEAN(ICOORDS[2:3])

;------------------------------
; ASSUME IF THERE ARE MULTIPLE DIRECTIONS THAT THE OBSERVATIONS ARE NEXT TO EACH OTHER
; GET NUMBER OF INDIVICUAL OBSERVATIONS (NUM VALUES DIVIDED BY DIRECTIONS)

  NOVAL     = -999.
  NUMNONREF = 5+12
  NOBSERS = n_elements(sensor_data[0,*])
  NBANDS    = N_ELEMENTS(BANDS_INDEX)
  vzaid = 1
  vaaid = 2
  szaid = 3
  saaid = 4

  ;IF ABS(NINOBS-long(NINOBS)) GT 0. THEN BEGIN
  ;  PRINT, 'ERROR, NOT ALL DIRECTIONS ARE PRESENT'
  ;  RETURN ;MAYBE JUST FILL THESE IN AS EMPTY THEN?
  ;ENDIF

;if parasol:::::
if pflag then begin
;get all of the uniq product names
uprds = prodnames[uniq(prodnames,sort(prodnames))]

paravza = make_array(n_elements(BANDS_INDEX),16,n_elements(uprds),/float,value=-999.)
paravaa = make_array(n_elements(BANDS_INDEX),16,n_elements(uprds),/float,value=-999.)

; loop over each product name and compute new vza and vaa angles
for iprd=0,n_elements(uprds)-1 do begin
;if iprd gt 0 then continue
print, 'product ', iprd, ' of' ,n_elements(uprds)
;print,'VZA ',SENSOR_DATA[1,0]
angles = get_parasol_viewing_geometries(uprds[iprd],icoords,site)
;returns,[nband,ndirs,2 angles]
paravza[*,*,iprd] = angles[*,*,0]
paravaa[*,*,iprd] = angles[*,*,1]
endfor
endif

;when loop over each parasol observation
; get find which product it's from, send the vza and vaa to find which direction
; return the vza and vaa for all bands within that direction


;------------------------------
; LOOP OVER EACH IND OBS
  dircount=0l
  FOR II=0l,NOBSERS-1 DO BEGIN;,NUM_DIRECTIONS DO BEGIN

;------------------------------
; CONVERT TIME FROM DECIMAL TO DD/MM/YYYY-HH:MM:SS, AND TODAYS DATE AS THE PROCESSING TIME STRING
  
    ACQ_TIME    = SENSOR_DATA[0,II]
    ;TTIME       = ACQ_TIME+DOUBLE(JULDAY(1, 0, FLOOR(ACQ_TIME), 0, 0, 0))
    if floor(acq_time) mod 4 eq 0 then diy=366 else diy=365
    ttime = diy*(acq_time-floor(acq_time))+DOUBLE(JULDAY(1, 0, FLOOR(ACQ_TIME), 0, 0, 0))
    CALDAT,TTIME,MONTH,DAY,YEAR,HOUR,MINUTE,SECOND

    MONTH       = MONTH Lt 10. ?  '0'+STRTRIM(STRING(MONTH,FORMAT='(I)'),2) : STRTRIM(STRING(MONTH,FORMAT='(I)'),2)
    DAY         = DAY Lt 10. ? '0'+STRTRIM(STRING(DAY,FORMAT='(I)'),2) : STRTRIM(STRING(DAY,FORMAT='(I)'),2)
    YEAR        = STRTRIM(STRING(YEAR,FORMAT='(I)'),2)
    HOUR        = HOUR Lt 10. ? '0'+STRTRIM(STRING(HOUR,FORMAT='(I)'),2) : STRTRIM(STRING(HOUR,FORMAT='(I)'),2)
    MINUTE      = MINUTE Lt 10. ? '0'+STRTRIM(STRING(MINUTE,FORMAT='(I)'),2) : STRTRIM(STRING(MINUTE,FORMAT='(I)'),2)
    SECOND      = SECOND Lt 10. ? '0'+STRTRIM(STRING(SECOND,FORMAT='(I)'),2) : STRTRIM(STRING(SECOND,FORMAT='(I)'),2)
    
    ACQ_STRING  = DAY+'/'+MONTH+'/'+YEAR+'-'+HOUR+':'+MINUTE+':'+SECOND
    PROC_STRING = ACQ_STRING;FOR NOW

;------------------------------
; GET TOA REFLECTANCE, STDEV AND VZA AND VAA

    TOA_REF = SENSOR_DATA[NUMNONREF+BANDs_INDEX,II]
    if sensor eq 'MODISA' then tband=22 else tband=nbands
    TOA_STD = SENSOR_DATA[NUMNONREF+tBAND+BANDs_INDEX,II]
  
  ;ADD EXCEPTION ON MODIS BANDS TO RESORT THE DATA>>> DONE, will be passed through bands_index!!!
  ; ADD IT TO THE DOUBLET EXTRACTION ROUTINE
  ; MERIS ET AL BANDS_INDEX = INDGEN(NBANDS) 
  ; MODISA BANDS_INDEX = [0,1,15,2,16,20,21,17,18,19]
   
    VZA = MAKE_ARRAY(NBANDS,/FLOAT,VALUE=SENSOR_DATA[VZAID,II])
    VAA = MAKE_ARRAY(NBANDS,/FLOAT,VALUE=SENSOR_DATA[VAAID,II])
    
  ;ADD EXCEPTION FOR PARASOL VIEWING GEOMETRY RECALCULATION>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    IF PFLAG EQ 1 THEN BEGIN
    ;SEND THE OBSERVATION TIME, REGION AND FILENAME, TO ANOTHER FUNCTION WHICH WILL GET THE 

    ;when loop over each parasol observation
    ; get find which product it's from, send the vza and vaa to find which direction
    ; return the vza and vaa for all bands within that direction

    prdid = where(uprds eq prodnames[ii])
    prdid = prdid[0]
    
    ;compute which direction
    ;returns,[nband,ndirs]
    tvza = reform(paravza[3,*,prdid],16)
    temp = abs(tvza-SENSOR_DATA[VZAID,II])
    p1 = min(temp)
    dirid = where(abs(temp-p1) lt 0.00001)
    dirid = dirid[0]
        
    ;para = get_parasol_viewing_geometries(ACQ_TIME,site,prodnames[ii],icoords,direction)
    ;READ IN THE PIXEL DATA, CALULATE THE NEW VZA AND VAA FOR EACH BAND
   
    VZA[*] = paravza[*,dirid,prdid]
    VAa[*] = paravaa[*,dirid,prdid]

    ENDIF
         
;    IF NUM_DIRECTIONS GT 1 THEN BEGIN
;      FOR JJ=1,NUM_DIRECTIONS-1 DO BEGIN
;        TOA_REF = [TOA_REF,SENSOR_DATA[NUMNONREF+BANDs_INDEX,II+JJ]]
;        TOA_STD = [TOA_STD,SENSOR_DATA[NUMNONREF+NBANDS+BANDs_INDEX,II+JJ]]
;        VZA     = [VZA,MAKE_ARRAY(NBANDS,/FLOAT,VALUE=SENSOR_DATA[VZAID,II+JJ])]
;        VAA     = [VAA,MAKE_ARRAY(NBANDS,/FLOAT,VALUE=SENSOR_DATA[VAAID,II+JJ])]
;      ENDFOR
;    ENDIF
  
    RES = WHERE(TOA_REF LT 0.,COUNT)
    IF COUNT GT 0 THEN TOA_REF[RES] = NOVAL
    RES = WHERE(TOA_STD LT 0.,COUNT)
    IF COUNT GT 0 THEN TOA_STD[RES] = NOVAL

;------------------------------
; GET SZA AND SAA AND NUMBER OF PIXELS

    PIX = numpixs[II]
    SZA = SENSOR_DATA[SZAID,II]
    SAA = SENSOR_DATA[SAAID,II]

  ;COPY QUICKLOOKS TO AN OUTPUT FOLDER>done
 QL_FOLDER =rdifol+'Site_'+site+dl+sensor+dl+'Proc_'+proc_ver+dl+year+dl
  TMP       = STRLEN(prodnames[ii])
  JPG_FILE  = FILE_SEARCH(QL_FOLDER,string(STRMID(prodnames[ii],0,TMP-4)+'*.jpg'))
  IF SENSOR EQ 'VEGETATION' THEN BEGIN
    TT = STRSPLIT(prodnames[ii],'_',/EXTRACT,/preserve_null)
    QLFOLDER = ql_folder+strjoin(tt[0:n_elements(tt)-4],'_')+dl+'0001'+dl
    JPG_FILE  = FILE_SEARCH(QLFOLDER,'*QUICKLOOK.jpg')
  endif
  if jpg_file[0] eq '' then begin
  print, 'missing quicklook:',prodnames[ii]
  endif else begin
  file_copy,jpg_file[0],jpgfol+dl+string(prodnames[ii]+'.jpg'),/overwrite

;------------------------------
; PRINT ALL DATA AS AN INDIVIDUAL LINE, SPACE DELIMITED, TO THE OUTPUTFILE

    PRINTF,OUTF,string(SENSOR+'_'+proc_ver),ACQ_STRING,PROC_STRING,SITE,TOA_REF,TOA_STD,$
      VZA,VAA,PIX,SITE_LAT,SITE_LON,SZA,SAA,string(prodnames[ii]+'.jpg'),$
      FORMAT = '(4(A,1H ),'+STRTRIM(FIX(4*nBANDS),2)+'(F11.6,1H ),1(i10,1H ),2(F10.3,1H ),2(F10.6,1H ),1(A))'

  endelse




  dircount++

  ENDFOR

;------------------------------
; CLOSE THE OUTPUT FILE

  FREE_LUN,OUTF

;------------------------------
; PRINT END STRING

  PRINT, 'COMPLETED SADE CONVERSION'

END