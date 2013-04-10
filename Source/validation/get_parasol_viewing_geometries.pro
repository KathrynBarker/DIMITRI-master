function get_parasol_viewing_geometries,pname,icoords,site

;find the data product
ifolder = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/'
dl=path_sep()
ff = ifolder+'Site_'+site+dl+'PARASOL'+dl+'Proc_Calibration_1'+dl
name = file_search(ff,pname)
compang = make_array(9,16,2,/float)


if name eq '' then stop

;read in the data
l1b_data = GET_PARASOL_L1B_DATA(name[0]) 

;get index of good data within icoords


for indirection=0,15 do begin
ROI_INDEX = WHERE($
            L1B_DATA.LATITUDE LT ICOORDS[0] AND $
            L1B_DATA.LATITUDE GT ICOORDS[1] AND $
            L1B_DATA.LONGITUDE LT ICOORDS[2] AND $
            L1B_DATA.LONGITUDE GT ICOORDS[3] and $;)
            L1B_DATA.REF_443NP[INdirection] GT 0.0) 

tempixvza = make_array(n_elements(roi_index),9,/float)
tempixvaa = make_array(n_elements(roi_index),9,/float)
for ipix = 0,n_elements(roi_index)-1 do begin

pvza = l1b_data[roi_index[ipix]].vza[indirection]
praa = l1b_data[roi_index[ipix]].raa[indirection]
pdvzc = l1b_data[roi_index[ipix]].DELTA_AV_COS_A[indirection]
pdvzs = l1b_data[roi_index[ipix]].DELTA_AV_sin_A[indirection]

newangles = compute_parasol_viewing_geometries(pvza,praa,pdvzc,pdvzs,/order)
tempixvza[ipix,*] = newangles.vza
tempixvaa[ipix,*] = newangles.raa

endfor

for ipband=0,9-1 do begin
nvza = mean(tempixvza[*,ipband])
nvaa = mean(L1B_DATA[roi_index].SAA-tempixvaa[*,ipband])
TEMP_ANGLES = DIMITRI_ANGLE_CORRECTOR(nvza,nvaa,0.0,0.0)
compang[ipband,indirection,0] = TEMP_ANGLES.vza
compang[ipband,indirection,1] = TEMP_ANGLES.vaa
endfor

endfor

;return the data
return,compang

end