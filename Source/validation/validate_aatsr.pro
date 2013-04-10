pro validate_aatsr
;compile routines
;define filename and icoords

case strupcase(!version.os_family) of
'WINDOWS':filename = 'Z:\DIMITRI_code\DIMITRI_2.0\Input\Site_Uyuni\AATSR\Proc_2nd_Reproc\2009\ATS_TOA_1PNMAP20090104_142316_000000482075_00182_35807_0001.N1'
'UNIX':filename = '/mnt/Demitri/DIMITRI_code/DIMITRI_2.0/Input/Site_Uyuni/AATSR/Proc_2nd_Reproc/2009/ATS_TOA_1PNMAP20090104_142316_000000482075_00182_35807_0001.N1'
else:filename = dialog_pickfile()
endcase

icoords  = [-20.00,-20.16,-67.45,-68.05]	
res = 0
;start testing routines

;log = 'meris_validation_log_globcolour.txt'
;openw,outf,log,/get_lun

print,'filename = ',filename
res = GET_aatsr_AUX_FILES(filename)
for i=0,n_elements(res)-1 do print,'AUX files: ',res[i]

res = GET_aatsr_L1B_reflectance(filename,0,'NADIR')
;help, res
print,'NADIR Radiance Band 0 [500:510]= ',RES[500:510]

res = GET_aatsr_L1B_reflectance(filename,3,'NADIR')
;help, res
print,'NADIR Radiance Band 3 [500:510]= ',RES[500:510]

res = GET_aatsr_L1B_reflectance(filename,0,'FWARD')
;help, res
print,'FWARD Radiance Band 0 [500:510]= ',RES[500:510]

res = GET_aatsr_L1B_reflectance(filename,3,'FWARD')
;help, res
print,'FWARD Radiance Band 3 [500:510]= ',RES[500:510]

res = GET_AATSR_LAT_LON(filename,'NADIR')
;;help,res
print,'NADIR Lat[500:510] = ',RES.LAT[500:510]
print,'NADIR Lon[500:510] = ',RES.LON[500:510]

res = GET_AATSR_QUICKLOOK(filename,/roi,icoords=icoords,/rgb)
print,'Quicklook = ',res

res = GET_AATSR_VIEWING_GEOMETRIES(filename,'NADIR')
;help, res
print,'NADIR sza[500:510] = ',RES.SZA[500:510]
print,'NADIR saa[500:510] = ',RES.SAA[500:510]
print,'NADIR vza[500:510] = ',RES.VZA[500:510]
print,'NADIR vaa[500:510] = ',RES.VAA[500:510]

;TEMP = './Input/Site_Uyuni/AATSR/Proc_2nd_Reproc/AATSR_TOA_REF.dat'
;RES  = GET_AATSR_TIMESERIES_PLOTS(TEMP)

end

