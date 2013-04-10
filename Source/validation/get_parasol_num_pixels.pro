pro remove_bad_parasol

regions = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
proc = 'Proc_Calibration_1'
years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']

ifolder = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/Site_'
dl = '/'
sensor = 'PARASOL'
STR = 'P*KD*'
count=0
outlog = '/mnt/Projects/MEREMSII/PARASOL_log/bad_products_log.txt'
openw,outf,outlog,/append

; loop over each validation site
for isite=0,N_elements(regions)-1 do begin
count=0

; loop over each year
for iyear=0,N_elements(years)-1 do begin

nfol = ifolder+regions[isite]+dl+sensor+dl+proc+years[iyear]
if not file_test(nfol,/directory) then goto, nofol

;find all parasol products
files = file_search(nfol,str)
if files[0] eq '' then goto,nofol

; loop over parasol products
for ifile=0l,n_elements(files)-1 do begin

;   get expected number of pixels 
npixs = get_parasol_num_pixels(filename)
esize = (npixs*738l)+180l

;   get file size in bytes
temp = file_info(filename)
fsize = temp.size

;   if not equal then begin - remove product and xounter product, append filename to list
  if esize ne fsize then begin
  count++
  printf,outf,regions[isite],' ',filename
  print,regions[isite],' ',filename
  stop
  file_delete,filename
  STRPUT,FILEname,'L',15
  file_delete,filename
  endif

;  endloop
endfor
;  endloop
nofol:
endfor
;  endloop
print, count, ' removals for ',regions[isite]
endfor

free_lun,outf

end


function get_parasol_num_pixels,filename

ENDIAN_SIZE = GET_ENDIAN_SIZE()

;------------------------------------------------
; OPEN THE PRODUCT AND READ NUMBER AND SIZE OF RECORDS

  IF KEYWORD_SET(VERBOSE) THEN PRINT, 'PARASOL L1B DATA: OPENING AND READING THE PRODUCT LOG'
  OPENR,IN_PARA,FILENAME,/GET_LUN
  TEMP = BYTARR(52)
  NUM_RECS = ULONG(1)
  REC_SIZE = ULONG(1)
  READU,IN_PARA,TEMP
  READU,IN_PARA,NUM_RECS
  READU,IN_PARA,REC_SIZE 

;------------------------------------------------
; SWAP ENDIAN IF NEEDED - DATA IS BIG ENDIAN

  IF ENDIAN_SIZE EQ 0 THEN BEGIN
    NUM_RECS = SWAP_ENDIAN(NUM_RECS)
    REC_SIZE = SWAP_ENDIAN(REC_SIZE)
  ENDIF
  
  return,num_recs
  
end
  