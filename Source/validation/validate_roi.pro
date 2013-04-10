pro validate_roi

;lats = [[1.4,1.45],[1.1,1.2]]
;lons = [[5.6,5.65],[5.61,5.66]]

;icoords = [1.3,1.2,5.63,5.62]

;res = CHECK_ROI_COVERAGE(LATs,LONs,ICOORDS)

;files = [$
;          'R:\MEREMSII\DIMITRI_2.0\Source\validation\ATS_TOA_1PRBCM20080102_134253_000000532064_00424_30538_0001.N1',$
;          'R:\MEREMSII\DIMITRI_2.0\Source\validation\ATS_TOA_1PRBCM20080127_135706_000000532065_00281_30896_0001.N1',$
;          'R:\MEREMSII\DIMITRI_2.0\Source\validation\ATS_TOA_1PRBCM20080203_133713_000000532065_00381_30996_0001.N1',$
;          'R:\MEREMSII\DIMITRI_2.0\Source\validation\ATS_TOA_1PRBCM20080215_135958_000000482066_00052_31168_0001.N1',$
;          'R:\MEREMSII\DIMITRI_2.0\Source\validation\ATS_TOA_1PRBCM20080222_134006_000000482066_00152_31268_0001.N1' $
;          ]
files = [$
          'MYD021KM.A2008001.1110.005.2009306140722.gscs_000500567695.hdf',$
          'MYD021KM.A2008002.1150.005.2009306154451.gscs_000500567695.hdf',$
          'MYD021KM.A2008003.1055.005.2009306170737.gscs_000500567695.hdf',$
          'MYD021KM.A2008005.1220.005.2009306183415.gscs_000500567695.hdf',$
          'MYD021KM.A2008012.1225.005.2009307084428.gscs_000500567695.hdf',$
          'MYD021KM.A2008029.1130.005.2009309120729.gscs_000500567695.hdf' ]

folder = '/mnt/Projects/MEREMSII/DIMITRI_2.0/Source/validation/'
;folder = 'R:\MEREMSII\DIMITRI_2.0\Source\validation\'
for jj=0,n_elements(files)-1 do begin

file = folder+files[jj]

    ;IFILE_TOA = GET_AATSR_L1B_REFLECTANCE(file,0,'NADIR')
    ;TOA_DIMS = SIZE(IFILE_TOA)

;geo = GET_AATSR_LAT_LON(file,'NADIR',TOA_DIMS[2],TOA_DIMS[1])
geo = GET_MODISA_LAT_LON(FILE)
icoords = [29.05,28.05,23.89,22.89]
t0 = systime(/seconds)
res2 = CHECK_ROI_COVERAGE(geo.lat,geo.lon,ICOORDS)
t1 = systime(/seconds) - t0
print, file, res2
;print, 'should be ',answers[jj] , ' is ', res2
;print,t1


endfor
end