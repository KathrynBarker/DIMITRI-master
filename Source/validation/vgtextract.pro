pro vgtextract

;assumes all data has been extracted using vgt extract

;define initial parameters
case strupcase(!version.os_family) of
'WINDOWS': begin
base_ofolder = 'E:\VGT_extract\'
dl = '\'
base_ifolder = 'E:\VGT_extract\'
end
'UNIX':begin
base_ofolder = '/mnt/Projects/MEREMSII/VGT_Data/ESA_BOUSSOLE/'
dl = '/'
base_ifolder = '/mnt/USB_drive02/VEGETATION/boussole/freeP/v2/'
end
endcase
;3,0,-58,-55
icoords      = [ 44.45         ,         42.25,         9.0,         6.8]
new_geo_str1 = ['  44.450000' ,'  42.250000','   9.000000','   6.800000']
new_geo_str2 = ['+044.450000' ,'+042.250000','+009.000000','+006.800000']
new_geo_str3 = ['  43.350000' ,'   7.900000','   2.250000','   2.200000']

;search for all files within output folder
cd,current=cdir
cd,base_ofolder
all_files = file_search('*.hdf')
all_files_short = strmid(all_files,0,22)

;get a list of all uniq products
uniq_files_short = all_files_short[uniq(all_files_short,sort(all_files_short))]

;loop over each uniq product
for i=0l,n_elements(uniq_files_short)-1 do begin

print, '>>>> Iteration : ',strtrim(i,2),' out of ',strtrim(n_elements(uniq_files_short)-1,2)

; create a new folder to keep all the products - if it already exists then skip it
new_folder = base_ofolder+uniq_files_short[i]
if file_test(new_folder,/directory) eq 1 then goto, skip_extract

file_mkdir,new_folder
new_folder = new_folder+dl+'0001'
file_mkdir,new_folder

; move all the extracted products to the new folder
str = uniq_files_short[i]+'*'
res = file_search(base_ofolder,str)
for j=1l,n_elements(res)-1 do begin
temp_file = res[j]
pos = strpos(temp_file,'ZIP')
pos2 = strpos(temp_file,'_20',/reverse_search)
new_file = '0001_'+strmid(temp_file,pos+4,pos2-pos-4)+'.HDF'
file_copy,res[j],new_folder+dl+new_file,/overwrite
;file_delete,res[j]geo_locatin
endfor

; find the original zip file
tempf = strmid(uniq_files_short[i],10,4)+dl+strmid(uniq_files_short[i],14,2)+dl+strmid(uniq_files_short[i],16,2)
original_zip_folder = base_ifolder+tempf
original_zip = file_search(original_zip_folder,str)

; read one of the old reflectance products and get dimensions
;unzip the old file
; read the log file
;delete all products but the zip file
cd,current=cdir
cd,original_zip_folder
if strupcase(!version.os_family) eq 'WINDOWS' then spawn,string('7z e -aoa '+original_zip[0]) $ 
  else spawn,string('7za e -aoa '+original_zip[0])
cd,cdir
extract_folder = original_zip_folder+dl
original_log = extract_folder+'0001_LOG.TXT'
;original_reflectance = GET_VEGETATION_L1B_REFLECTANCE(original_log) 
; read one of the old reflectance products and get dimensions
original_geo_location = GET_VEGETATION_LAT_LON(original_log)

lat_row = where(original_geo_location.lat[0,*] lt icoords[0] and original_geo_location.lat[0,*] gt icoords[1])
lon_col = where(original_geo_location.lon[*,0] lt icoords[2] and original_geo_location.lon[*,0] gt icoords[3])

if lat_row[0] eq -1 or  lon_col[0] eq -1 then goto, no_cord


new_lat_indexes = [lat_row[0],lat_row[n_elements(lat_row)-1]]
new_lon_indexes = [lon_col[0],lon_col[n_elements(lon_col)-1]]


log_data = string(read_binary(original_log))

; replace the lon/lat with site lon/lat
POS = STRPOS(log_data,'CARTO_UPPER_LEFT_X')
strput,log_data,new_geo_str1[3],pos+26
POS = STRPOS(log_data,'CARTO_UPPER_LEFT_Y')
strput,log_data,new_geo_str1[0],pos+26
POS = STRPOS(log_data,'CARTO_UPPER_RIGHT_X')
strput,log_data,new_geo_str1[2],pos+26
POS = STRPOS(log_data,'CARTO_UPPER_RIGHT_Y')
strput,log_data,new_geo_str1[0],pos+26
POS = STRPOS(log_data,'CARTO_LOWER_RIGHT_X')
strput,log_data,new_geo_str1[2],pos+26
POS = STRPOS(log_data,'CARTO_LOWER_RIGHT_Y')
strput,log_data,new_geo_str1[1],pos+26
POS = STRPOS(log_data,'CARTO_LOWER_LEFT_X')
strput,log_data,new_geo_str1[3],pos+26
POS = STRPOS(log_data,'CARTO_LOWER_LEFT_Y')
strput,log_data,new_geo_str1[1],pos+26

POS = STRPOS(log_data,'CARTO_CENTER_X')
strput,log_data,new_geo_str3[1],pos+26
POS = STRPOS(log_data,'CARTO_CENTER_Y')
strput,log_data,new_geo_str3[0],pos+26
POS = STRPOS(log_data,'CARTO_HEIGHT')
strput,log_data,new_geo_str3[2],pos+26
POS = STRPOS(log_data,'CARTO_WIDTH')
strput,log_data,new_geo_str3[3],pos+26

POS = STRPOS(log_data,'GEO_UPPER_LEFT_LAT')
strput,log_data,new_geo_str2[0],pos+26
POS = STRPOS(log_data,'GEO_UPPER_LEFT_LON')
strput,log_data,new_geo_str2[3],pos+26
POS = STRPOS(log_data,'GEO_UPPER_RIGHT_LAT')
strput,log_data,new_geo_str2[0],pos+26
POS = STRPOS(log_data,'GEO_UPPER_RIGHT_LON')
strput,log_data,new_geo_str2[2],pos+26
POS = STRPOS(log_data,'GEO_LOWER_RIGHT_LAT')
strput,log_data,new_geo_str2[1],pos+26
POS = STRPOS(log_data,'GEO_LOWER_RIGHT_LON')
strput,log_data,new_geo_str2[2],pos+26
POS = STRPOS(log_data,'GEO_LOWER_LEFT_LAT')
strput,log_data,new_geo_str2[1],pos+26
POS = STRPOS(log_data,'GEO_LOWER_LEFT_LON')
strput,log_data,new_geo_str2[3],pos+26


POS1 = STRPOS(log_data,'IMAGE_UPPER_RIGHT_COL')    
POS2 = STRPOS(log_data,'IMAGE_LOWER_RIGHT_ROW') 
POS3 = STRPOS(log_data,'IMAGE_LOWER_RIGHT_COL')
POS4 = STRPOS(log_data,'IMAGE_LOWER_LEFT_ROW')
POS5 = STRPOS(log_data,'IMAGE_LOWER_LEFT_COL')
pos6 = STRPOS(log_data,'IMAGE_CENTER_ROW')
pos7 = STRPOS(log_data,'IMAGE_CENTER_COL')
pos8 = STRPOS(log_data,'GEOM_CHAR_REF')
size_1 = pos2-pos1-26
size_2 = pos3-pos2-26
size_3 = pos7-pos6-26
size_4 = pos8-pos7-26

tt = strtrim(string(fix(2+new_lat_indexes[1]-new_lat_indexes[0])),2)
ttt = strjoin([tt,make_array(size_2-strlen(tt),value=' '),string(10b)])

ll = strtrim(string(fix(2+new_lon_indexes[1]-new_lon_indexes[0])),2) 
lll= strjoin([ll,make_array(size_1-strlen(ll),value=' '),string(10b)])

trow = fix(ttt)/2
trow= strjoin([strtrim(string(trow),2),make_array(size_1-strlen(strtrim(string(trow),2)),value=' '),string(10b)])
tcol = fix(lll)/2
tcol= strjoin([strtrim(string(tcol),2),make_array(size_2-strlen(strtrim(string(tcol),2)),value=' '),string(10b)])

p1 = strmid(log_data,0,pos1+26)
p2 = strmid(log_data,pos2,26)
p3 = strmid(log_data,pos3,26)
p4 = strmid(log_data,pos4,26)
p5 = strmid(log_data,pos5,pos6-pos5)
p6 = strmid(log_data,pos6,26)
p7 = strmid(log_data,pos7,26)
p8 = strmid(log_data,pos8,strlen(log_data)-pos8)

log_data = strjoin([p1,lll,p2,ttt,p3,lll,p4,ttt,p5,p6,trow,p7,tcol,p8])

new_log = new_folder+dl+'0001_LOG.TXT'
openw,lun,new_log,/get_lun
printf,lun,log_data
free_lun,lun

; open the orinal og,ag and wvp products

  i_dat = [extract_folder+'0001_AG.HDF',extract_folder+'0001_OG.HDF',extract_folder+'0001_WVG.HDF']
  o_dat = [new_folder+dl+'0001_AG.HDF',new_folder+dl+'0001_OG.HDF',new_folder+dl+'0001_WVG.HDF']
  
  for jj=0l,2 do begin
  hdfid = HDF_SD_START(i_dat[jj], /read)
  sd_id = HDF_SD_SELECT(hdfid,0)
  HDF_SD_GETDATA, sd_id, data
  HDF_SD_ENDACCESS, sd_id
  HDF_SD_END, hdfid
  dims = size(data)

  interpolated_data = rebin(data,dims(1)*100,dims(2)*100)
  y_r=100.*ceil((2+new_lat_indexes[1]-new_lat_indexes[0])/100.)
  x_r=100.*ceil((2+new_lon_indexes[1]-new_lon_indexes[0])/100.)
  extract_data = interpolated_data[new_lon_indexes[0]:new_lon_indexes[0]+x_r,new_lat_indexes[0]:new_lat_indexes[0]+y_r]
  
  rebin_data = congrid(extract_data,x_r/100,y_r/100)
  hdfid = HDF_SD_START(o_dat[jj], /create)
  SD_id = HDF_SD_CREATE(hdfid, 'MEASURE VALUE',[x_r/100,y_r/100])
  HDF_SD_ADDDATA, SD_id, rebin_data 
  HDF_SD_ENDACCESS, sd_id
  HDF_SD_END, hdfid
  endfor

;extract the correct  angular data

  i_dat = [extract_folder+'0001_SZA.HDF',extract_folder+'0001_SAA.HDF',extract_folder+'0001_VZA.HDF',extract_folder+'0001_VAA.HDF']
  o_dat = [new_folder+dl+'0001_SZA.HDF',new_folder+dl+'0001_SAA.HDF',new_folder+dl+'0001_VZA.HDF',new_folder+dl+'0001_VAA.HDF']
  
  for jj=0l,3 do begin
  
  IF FILE_TEST(O_dat[jj]) EQ 1 THEN FILE_DELETE,O_dat[jj]
  hdfid = HDF_SD_START(i_dat[jj], /read)
  sd_id = HDF_SD_SELECT(hdfid,0)
  HDF_SD_GETDATA, sd_id, data
  HDF_SD_ENDACCESS, sd_id
  HDF_SD_END, hdfid
  dims = size(data)

  interpolated_data = rebin(data,dims(1)*8,dims(2)*8)
  y_r=8.*ceil((2+new_lat_indexes[1]-new_lat_indexes[0])/8.) < dims(2)*8-1
  x_r=8.*ceil((2+new_lon_indexes[1]-new_lon_indexes[0])/8.) < dims(1)*8-1
  
  TOPVALY = new_lat_indexes[0]+y_r < dims(2)*8-1
  TOPVALX = new_lon_indexes[0]+x_r < dims(1)*8-1
  
  extract_data = interpolated_data[new_lon_indexes[0]:TOPVALX,new_lat_indexes[0]:TOPVALY]
  
  rebin_data = congrid(extract_data,(x_r/8)>1,(y_r/8)>1)
  hdfid = HDF_SD_START(o_dat[jj], /create)
  SD_id = HDF_SD_CREATE(hdfid, 'ANGLES_VALUES',[(x_r/8)>1,(y_r/8)>1])
  HDF_SD_ADDDATA, SD_id, rebin_data 
  HDF_SD_ENDACCESS, sd_id
  HDF_SD_END, hdfid
  endfor

; copy the rig file across to new folder
  file_copy,extract_folder+'0001_RIG.TXT',new_folder+dl+'0001_RIG.TXT',/overwrite

no_cord:

; find all hdf files and delete
files_for_deletion = file_search(original_zip_folder,'*.hdf')
for kk=0,n_elements(files_for_deletion)-1 do file_delete,files_for_deletion[kk]

skip_extract:

endfor
print, 'finished'
;need to delete unzipped files?

;
;
;;for a given file
;file = 'C:\Documents and Settings\Christopher\Desktop\VGT_extract\V2KRNP____20090102F025.ZIP'
;output_folder = 'C:\Documents and Settings\Christopher\Desktop\VGT_extract\chris_extract\'
;icoords      = [44.56         ,        44.00,         10.0,          8.0]
;new_geo_str1 = ['  44.560000' ,'  44.000000','  10.000000','   8.000000']
;new_geo_str2 = ['+044.560000' ,'+044.000000','+010.000000','+008.000000']
;new_geo_str3 = ['  44.280000' ,'   9.000000','   0.560000','   2.000000']
;
;res=file_info(output_folder)
;if res.exists eq 0 then file_mkdir,output_folder
;
;;unzip the zip product
;;spawn,string('unzip -n '+file)
;
;product_names = ['AG.HDF','B0.HDF','B2.HDF','B3.HDF','MIR.HDF','OG.HDF','RIG.TXT','SAA.HDF',$
;                  'SM.HDF','SZA.HDF','VAA.HDF','VZA.HDF','WVG.HDF']
;proc_typ = [2,1,1,1,1,2,0,1,1,1,1,1,2]
;
;;sort out log file
;log_data = string(read_binary('0001_LOG.TXT'))
;POS = STRPOS(log_data,'CARTO_UPPER_LEFT_X')
;
;strput,log_data,new_geo_str1[3],pos+0*37
;strput,log_data,new_geo_str1[0],pos+1*37
;strput,log_data,new_geo_str1[2],pos+2*37
;strput,log_data,new_geo_str1[0],pos+3*37
;strput,log_data,new_geo_str1[2],pos+4*37
;strput,log_data,new_geo_str1[1],pos+5*37
;strput,log_data,new_geo_str1[3],pos+6*37
;strput,log_data,new_geo_str1[1],pos+7*37
;
;strput,log_data,new_geo_str3[1],pos+8*37
;strput,log_data,new_geo_str3[0],pos+9*37
;strput,log_data,new_geo_str3[2],pos+10*37
;strput,log_data,new_geo_str3[3],pos+11*37
;
;strput,log_data,new_geo_str2[0],pos+12*37
;strput,log_data,new_geo_str2[3],pos+13*37
;strput,log_data,new_geo_str2[0],pos+14*37
;strput,log_data,new_geo_str2[2],pos+15*37
;strput,log_data,new_geo_str2[1],pos+16*37
;strput,log_data,new_geo_str2[2],pos+17*37
;strput,log_data,new_geo_str2[1],pos+18*37
;strput,log_data,new_geo_str2[3],pos+19*37
;
;;find index of pixels to be extracted using geolocation
;;loop over each extracted file
;; read the products data
;; extract data pixels as identified by geo check
;; save data back as another hdf file in output folder
;; if ag, wvg or og then interpolate to main product grid, extract geo pixels, and rebin/regrid it back to the reduxed resolution grid
;; endloop
;; copy log file and update coordinates to geo location
;




end




