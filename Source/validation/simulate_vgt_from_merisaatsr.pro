pro simulate_VGT_from_MERISAATSR

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define variable of the simulation
;;;;;;;;;;;;;;;;;;;;;;;;;;
SZA=30
SAA=0
VZA=30
VAA=0
wv=1.
Ozone=0.3
month=1
day=1
aerosol_type=1
AOT_550=.2
Target_altitude=-0.0
Sensor_altitude=-1000 
aerosol_type=1
wl=[0.4, 2.0]
surface_type=3 ; 1: vegetation, 2: water, 3:sand

; Prepare input file
sixs_write_input_file_6s, SZA, SAA, VZA, VAA, month, day, WV, Ozone, aerosol_type, AOT_550,Target_altitude,Sensor_altitude, wl, surface_type


;;;;;;;;;;;;;;;;;;;;;;;;;;
; Run 6s
;;;;;;;;;;;;;;;;;;;;;;;;;;
spawn, 'rm out6svegetation.txt'
spawn, 'sixs_41_Thuillier_2002_Nieke_band < in6svegetation > out6svegetation.txt'

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Open resulting spectrum
;;;;;;;;;;;;;;;;;;;;;;;;;;
spectrum=READ_6S_SPECTRUM('out6svegetation.txt')

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot the TOA radiance
; L = rho x E0 x cos (theta_s) / Pi
;;;;;;;;;;;;;;;;;;;;;;;;;;
L_toa=spectrum(10,*)*spectrum(6,*)/spectrum(9,*)/spectrum(9,*)/!pi*cos(0.)
window, /free, xsize=800
device, decompose=0
loadct, 39
plot,spectrum(0,*), L_toa, background=255, color=0, xtitle='Wavelength in micrometer' , ytitle='TOA radiance in W.m-2.micrometer-1', xrange=[0.4,2.0]

;; Transmission is saved as an IDL file
;transmission_O3_O2=spectrum[0:1, *]
;save, transmission_O3_O2, filename='transmission_O3_O2.sav'
;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot the TOA reflectance
;;;;;;;;;;;;;;;;;;;;;;;;;;
rho_toa=spectrum(10,*)
window, /free, xsize=800
device, decompose=0
loadct, 39
plot,spectrum(0,*), rho_toa, background=255, color=0, xrange=[0.4,2.0], xtitle='Wavelength in micrometer' , ytitle='TOA reflectance'

;;;;;;;;;;;;;;;;;;;;;;;;;;
; Read RSR
;;;;;;;;;;;;;;;;;;;;;;;;;;

nb_wavelength=1600
wavelength=indgen(nb_wavelength)*(wl[1]-wl[0])/nb_wavelength+wl[0]
meris_rsr=fltarr(15,nb_wavelength )

meris_rsr_files = FILE_SEARCH('MERIS_Band*response.txt')  
for i=0, 14 do begin
	rsr = read_meris_rsr(meris_rsr_files[i]) 
	rsr_interpolated=interpol(rsr[1,*], rsr[0,*]/1000., wavelength) >0.
	meris_rsr[i,*]=rsr_interpolated
endfor

plot, wavelength, meris_rsr[0,*], background=255, color=0, xtitle='Wavelength in nm', ytitle='Relative spectral response'
for i=1, 14 do begin
	oplot, wavelength, meris_rsr[i,*], color=0
endfor

; AATSR bands
aatsr_rsr=fltarr(nb_wavelength)
 
rsr = read_aatsr_rsr('AATSR_response.txt') 
aatsr_rsr=interpol(rsr[1,*], rsr[0,*], wavelength) >0.
oplot, wavelength, aatsr_rsr, color=0

; VGT bands
vgt_rsr=fltarr(4,nb_wavelength )
vgt_rsr_files = FILE_SEARCH('vgt*band*.txt')  
for i=0, 3 do begin
	rsr = read_vgt_rsr(vgt_rsr_files[i]) 
	rsr_interpolated=interpol(rsr[1,*], rsr[0,*]/1000., wavelength) >0.
	vgt_rsr[i,*]=rsr_interpolated
	oplot, wavelength, vgt_rsr[i,*],color=250
endfor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compute the TOA reflectance spectrum interpolated from MERIS + AATSR measurements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Interpolate the 6S spectrum
rho_toa=interpol(rho_toa, spectrum[0,*], wavelength)

central_wl_s3=[412.5, 443.5, 490., 510., 560., 620., 664., 681., 709., 754., 760.625, 779., 865.,885., 900., 1610.]
central_wl_s3=central_wl_s3/1000.
S3_reflectance_measurements=fltarr(16)

for i=0,14 do begin
	S3_reflectance_measurements[i]=total(rho_toa*meris_rsr[i,*])/total(meris_rsr[i,*])
endfor

S3_reflectance_measurements[15]=total(rho_toa*aatsr_rsr[*])/total(aatsr_rsr[*])


;S3_interpol_rho_toa=interpol(S3_reflectance_measurements, central_wl_s3, wavelength)
S3_interpol_rho_toa=interpol([S3_reflectance_measurements[0:14], S3_reflectance_measurements[13],S3_reflectance_measurements[15] ],[central_wl_s3[0:14],1.0,central_wl_s3[15]], wavelength)

window, /free, xsize=800
device, decompose=0
loadct, 39

plot, wavelength, S3_interpol_rho_toa,  color=0, background=255,xtitle='Wavelength in micrometer' , ytitle='TOA reflectance', xrange=[0.4,2.0]
oplot, wavelength, S3_interpol_rho_toa,  color=250
oplot, wavelength, rho_toa, color=0
oplot, central_wl_s3, S3_reflectance_measurements, psym=2, color=250


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compute the VGT TOA reflectance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vgt_reflectance_measurements=fltarr(4)
for i=0,3 do begin
	vgt_reflectance_measurements[i]=total(rho_toa*vgt_rsr[i,*])/total(vgt_rsr[i,*])
endfor

vgt_reflectance_S3_interpol=fltarr(4)
for i=0,3 do begin
	vgt_reflectance_S3_interpol[i]=total(S3_interpol_rho_toa*vgt_rsr[i,*])/total(vgt_rsr[i,*])
endfor
print, 'The reflectance in VGT band are:', vgt_reflectance_measurements

print, 'The error in % on each band using simple interpolation:'
print, (vgt_reflectance_S3_interpol-vgt_reflectance_measurements)/vgt_reflectance_measurements*100.



; Compute the pseudo-optical thicknesses
restore, filename='transmission_O2.sav'
O2_OT=-0.5*alog(transmission_O2[1,*])
restore, filename='transmission_O3_O2.sav'
O3_OT=-0.5*alog(transmission_O3_O2[1,*]/transmission_O2[1,*])
restore, filename='transmission_H2O_O2.sav'
H2O_OT=-0.5*alog(transmission_H2O_O2[1,*]/transmission_O2[1,*])


;window, /free, xsize=800
;device, decompose=0
;loadct, 39
;
;plot, transmission_O2[0,*], transmission_O2[1,*], background=255, color=0, xtitle='Wavelength in micometer', ytitle='Total up and down welling gaseous transmission'
;oplot, transmission_O2[0,*], transmission_O2[1,*], color=100
;oplot, transmission_O2[0,*], transmission_O3_O2[1,*]/transmission_O2[1,*], color=50
;oplot, transmission_O2[0,*], transmission_H2O_O2[1,*]/transmission_O2[1,*], color=250


;;;;;;;;;;;;;;;;;;;;;
; Compute the reconstructed spectrum from S-3 interpolation and gaseous absorption
;;;;;;;;;;;;;;;;;;;;;

;;;;;
; First correct S-3 for absorption
;;;;;

; Interpolate the OT to the high resolution wavelength
; Compute the pseudo-OT for S-3 bands
O2_OT=interpol(reform(O2_OT),transmission_O2[0,*], wavelength)
O3_OT=interpol(reform(O3_OT),transmission_O2[0,*], wavelength)
H2O_OT=interpol(reform(H2O_OT),transmission_O2[0,*], wavelength)
tot_trans=exp(-(O2_OT+O3_OT*ozone/0.3+H2O_OT*wv/2.0)*(1./cos(SZA/180.*!pi)+1./cos(VZA/180.*!pi)))


S3_rho_toa_gc=fltarr(16)
for i=0,14 do begin
	S3_rho_toa_gc[i]=S3_reflectance_measurements[i]/(total(tot_trans*meris_rsr[i,*])/total(meris_rsr[i,*]))	
	;print, (total(tot_trans*meris_rsr[i,*])/total(meris_rsr[i,*]))	

endfor

S3_rho_toa_gc[15]=S3_reflectance_measurements[15]/(total(tot_trans*aatsr_rsr)/total(aatsr_rsr))	


; Reconstruct TOA spectrum
S3_interpol_rho_toa_gc=interpol([S3_rho_toa_gc[0:14],S3_rho_toa_gc[13],S3_rho_toa_gc[15]], [central_wl_s3[0:14],1.0,central_wl_s3[15]], wavelength)

; Correct TOA spectrum for absorption
simul_rho_toa=S3_interpol_rho_toa_gc*tot_trans

;window, /free, xsize=800
;device, decompose=0
;loadct, 39
;
;plot, wavelength, rho_toa,  color=0, background=255,xtitle='Wavelength in micrometer' , ytitle='TOA reflectance', xrange=[0.4,2.0]
oplot, wavelength, S3_interpol_rho_toa_gc, color=150
oplot, wavelength, simul_rho_toa, color=50

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compute the VGT TOA reflectance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;


vgt_reflectance_S3_interpol_corr=fltarr(4)
for i=0,3 do begin
	vgt_reflectance_S3_interpol_corr[i]=total(simul_rho_toa*vgt_rsr[i,*])/total(vgt_rsr[i,*])
endfor
print, 'The error in % on each band using simple interpolation:'
print, (vgt_reflectance_S3_interpol_corr-vgt_reflectance_measurements)/vgt_reflectance_measurements*100.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot the difference between the reconstructed spectrum and the initial one
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

window, /free, xsize=800
device, decompose=0
loadct, 39

plot, wavelength, (simul_rho_toa-rho_toa)/rho_toa*100.,  color=0, background=255,xtitle='Wavelength in micrometer' , ytitle='Difference in %', xrange=[0.4,2.0], yrange=[-100, 100]
 
for i=0, 3 do begin
	oplot, wavelength, vgt_rsr[i,*]*100,color=250
endfor


end
