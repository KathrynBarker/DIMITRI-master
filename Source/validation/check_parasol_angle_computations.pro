pro check_parasol_angle_computations

folder = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/Site_Amazon/PARASOL/Proc_Calibration_1/2009/'
file = 'P3L1TBG1094025KD_n03_00_N00_00_w058_00_W055_00'

RES = GET_PARASOL_L1B_DATA(folder+FILE)

pixel_data = res[20,20]

davca = pixel_data.delta_av_cos_a
davsa = pixel_data.delta_av_sin_a
vza = pixel_data.vza[0]
raa = pixel_data.raa[0]

res = compute_parasol_viewing_geometries(vza,raa,davca,davsa)

print,'VZA - org ',vza
print,'VZA - com ', res.vza
print,'RAA - org ',RAa
print,'VZA-  com ',res.raa

stop
end