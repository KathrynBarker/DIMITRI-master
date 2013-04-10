
pro create_new_tar

;create_dimitri_folders
;wait,900
;print, 'finished waiting to start copying...
;move_vgt_jpegs
move_dimitri_savs
move_dimitri_jpegs
;move_dimitri_savs
move_vgt_jpegs
end


pro create_dimitri_folders

dl = '/'
input_folder = '/mnt/Projects/MEREMSII/DIMITRI/20120413/DIMITRI_2.0/'

sites = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']

sensors = ['AATSR','ATSR2','MERIS','MERIS','MODISA','PARASOL','VEGETATION']
proc_vers = ['2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5','Calibration_1','Calibration_1']
years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']

;loop over each site
for i=0,n_elements(sites)-1 do begin
sf = input_folder+'Site_'+sites[i]
file_mkdir,sf;input_folder

; loop over each sensor
for j=0,n_elements(sensors)-1 do begin
; if folder doesn;t exits then create
tf = sf+dl+sensors[j]
if file_test(tf,/directory) eq 0 then file_mkdir,tf
; if proc folder doesn;t exist then create
pf = tf+dl+'Proc_'+proc_vers[j]
file_mkdir,pf
; ;loop over each year, if it doesn;t exist then create new one
for k = 0,n_elements(years)-1 do begin
yf = pf+dl+years[k]
file_mkdir,yf
endfor

;end loop
endfor
;endlopop
endfor


end


pro move_dimitri_jpegs

start  = systime()
dl = '/'
;input_folder = 'Z:\DIMITRI_code\DIMITRI_2.0\Input\'
;output_folder= 'Z:\temp_data_for_AR\DIMITRI_2.0\Input\' 

input_folder = '/mnt/Projects/MEREMSII/DIMITRI/20120305/DIMITRI_2.0/Input/';'/mnt/Demitri/DIMITRI_code/DIMITRI_2.0/Input/'
output_folder= '/mnt/Projects/MEREMSII/DIMITRI/20120413/DIMITRI_2.0/Input/';'/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/'
;'/mnt/Projects/MEREMSII/DIMITRI/20120413/DIMITRI_2.0/Input/'
;'/mnt/Projects/MEREMSII/DIMITRI/20120305/DIMITRI_2.0/Input/'

;sites = ['SIO']
;sensors = ['PARASOL']
;proc_vers = ['Calibration_1']
;years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']

sites = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
sensors = ['AATSR','ATSR2','MERIS','MERIS','MODISA','PARASOL']
proc_vers = ['2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5','Calibration_1']
years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']


counter = double(0.0)

;loop over each site
for i=0,n_elements(sites)-1 do begin
for j=0,n_elements(sensors)-1 do begin
for k=0,n_elements(years)-1 do begin
  tt = 'Site_'+sites[i]+dl+sensors[j]+dl+'Proc_'+proc_vers[j]+dl+years[k]
  ifolder = input_folder+tt
  if file_test(ifolder) eq 1 then begin
    res = file_search(ifolder,'*.jpg')
    if res[0] ne '' then for m=0l,n_elements(res)-1 do begin
      file_copy,res[m],output_folder+tt 
      counter++
    endfor
  endif
endfor
print, 'completed site: ',sites[i],' for sensor: ',sensors[j]
endfor
endfor

etime = systime()

print,'moved ',counter,' jpgs'
print,'s: ',start
print,'e: ',etime

end

pro move_dimitri_savs

start  = systime()
dl = '/'
;input_folder = 'Z:\DIMITRI_code\DIMITRI_2.0\Input\'
;output_folder= 'Z:\temp_data_for_AR\DIMITRI_2.0\Input\' 

;input_folder = 'Z:\DIMITRI_code\DIMITRI_2.0\Input\'
;output_folder= 'R:\MEREMSII\DIMITRI_2.0\Input\'

;input_folder = '/mnt/Demitri/DIMITRI_code/DIMITRI_2.0/Input/'
;output_folder= '/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/'

;input_folder = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/'
;output_folder= '/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/'
input_folder = '/mnt/Projects/MEREMSII/DIMITRI/20120305/DIMITRI_2.0/Input/';'/mnt/Demitri/DIMITRI_code/DIMITRI_2.0/Input/'
output_folder= '/mnt/Projects/MEREMSII/DIMITRI/20120413/DIMITRI_2.0/Input/';'/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/'

;sites = ['Amazon','BOUSSOLE','DomeC','Libya','SIO','SPG','TuzGolu','Uyuni']
;sensors = ['AATSR','ATSR2','MERIS','MERIS','MODISA','PARASOL','VEGETATION']
;proc_vers = ['2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5','Calibration_1','Calibration_1']
sites = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
sensors = ['AATSR','ATSR2','MERIS','MERIS','MODISA','PARASOL','VEGETATION']
proc_vers = ['2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5','Calibration_1','Calibration_1']


counter = double(0.0)

;loop over each site
for i=0,n_elements(sites)-1 do begin
for j=0,n_elements(sensors)-1 do begin

  tt = 'Site_'+sites[i]+dl+sensors[j]+dl+'Proc_'+proc_vers[j]+dl
  ifolder = input_folder+tt
  if file_test(ifolder) eq 1 then begin
    res = file_search(ifolder,string('*'+sensors[j]+'_*'))
    if res[0] ne '' then for m=0l,n_elements(res)-1 do file_copy,res[m],output_folder+tt,/overwrite 
  endif
print, 'completed site: ',sites[i],' for sensor: ',sensors[j]
endfor
endfor

etime = systime()
print,'s: ',start
print,'e: ',etime

end

pro move_vgt_jpegs

start  = systime()
dl = '/'

;input_folder = '/mnt/Demitri/DIMITRI_code/DIMITRI_2.0/Input/'
;output_folder= '/mnt/Demitri/DIMITRI_tar_dist/DIMITRI_2.0/Input/'

;input_folder = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/'
;output_folder= '/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/'
input_folder = '/mnt/Projects/MEREMSII/DIMITRI/20120305/DIMITRI_2.0/Input/';'/mnt/Demitri/DIMITRI_code/DIMITRI_2.0/Input/'
output_folder= '/mnt/Projects/MEREMSII/DIMITRI/20120413/DIMITRI_2.0/Input/';'/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/'

;sites = ['Libya4']
sites = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
sensors = ['VEGETATION']
proc_vers = ['Calibration_1']
years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']

counter = double(0.0)

;loop over each site
for i=0,n_elements(sites)-1 do begin
for j=0,n_elements(sensors)-1 do begin
for k=0,n_elements(years)-1 do begin
  tt = 'Site_'+sites[i]+dl+sensors[j]+dl+'Proc_'+proc_vers[j]+dl+years[k]
  ifolder = input_folder+tt+dl
  if file_test(ifolder) eq 1 then begin
    res = file_search(ifolder,'*.jpg')
    
    if res[0] ne '' then begin
    
    for m=0,N_elements(res)-1 do begin
    
    
    ofold = output_folder+strmid(res[m],strlen(input_folder),strlen(res[m])-strlen(input_folder))
   file_mkdir,strmid(ofold,0,strlen(ofold)-18)
   file_copy,res[m],ofold 
  
   
    endfor
    
    
    
    
    endif
    
    
       
    
    
    
  endif  
   
endfor
print, 'completed site: ',sites[i],' for sensor: ',sensors[j]
endfor
endfor

etime = systime()

print,'s: ',start
print,'e: ',etime

end
