pro sort_VGT_VAA

;input folder
site = 'Uyuni'
dl = '/'
ifol = '/mnt/Projects/MEREMSII/VGT_Data/vaa_extracts/'+site+'/'
ofol = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/'+'Site_'+site+'/VEGETATION/Proc_Calibration_1/'

;output folder

;loop over each file in input folder
sstr='*.HDF'
vaafiles = file_search(ifol,sstr)

if vaafiles[0] eq '' then return

for ii=0l,n_elements(vaafiles)-1 do begin
print,ii,' of ',n_elements(vaafiles)
; extract year, and product code
year = strmid(vaafiles[ii],strlen(ifol)+10,4)
newfol1 = strmid(vaafiles[ii],strlen(ifol)+0,22)
newfol2 = '0001'
newfil1 = '0001_VAA.HDF'

if file_test(ofol+year+dl+newfol1) ne 1 then continue

target = filepath(newfil1,root_dir=ofol,subdir=[year,newfol1,newfol2])
; copy file to iomega hdd overwriting the previous file
file_copy,vaafiles[ii],target,/overwrite
endfor


print, 'completed VAA sorting...'

end