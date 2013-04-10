PRO COMPARE_DIMITRI_CNES_SADE

;SADE1 = '/mnt/Projects/MEREMSII/WG_Reference_Dataset_2/Libya4/Libya4_PARASOL_Calibration_1.SADE'
;SADE2 = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/CNES/Libya4_CNES/Libya4_CNES/CNES_Libya4_PARASOL_Calibration_1.SADE'
sensor = 'VEGETATION'

SADE1 = 'R:\MEREMSII\WG_Reference_Dataset\distributable_files\Libya4\Libya4_VEGETATION_Calibration_1.SADE'
SADE2 = 'R:\MEREMSII\WG_Reference_Dataset\CNES\Libya4_CNES\Libya4_CNES\CNES_Libya4_VEGETATION_Calibration_1.SADE'
;sensor = 'VEGETATION'

;SADE1 = 'R:\MEREMSII\WG_Reference_Dataset\distributable_files\Libya4\Libya4_MERIS_2nd_Reprocessing.SADE'
;SADE2 = 'R:\MEREMSII\WG_Reference_Dataset\CNES\Libya4_CNES\Libya4_CNES\CNES_Libya4_MERIS_2nd_Reprocessing.SADE'
;sensor = 'MERIS'

;SADE1 = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/distributable_files/Libya4/Libya4_MERIS_2nd_Reprocessing.SADE'
;SADE2 = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/CNES/Libya4_CNES/Libya4_CNES/CNES_Libya4_MERIS_2nd_Reprocessing.SADE'
;sensor = 'MERIS'

toaref1 = CONVERT_SADE_TO_DIMITRI(SADE1,SENSOR)
toaref2 = CONVERT_SADE_TO_DIMITRI(SADE2,SENSOR)

;; try it with new dataset
;restore,'/mnt/Projects/MEREMSII/DIMITRI_2.0/Input/Site_Libya4/VEGETATION/Proc_Calibration_1/VEGETATION_TOA_REF.dat'
;restore,'R:\MEREMSII\DIMITRI_2.0\Input\Site_Libya4\VEGETATION\Proc_Calibration_1\VEGETATION_TOA_REF.dat'
;toaref1 = sensor_l1b_ref
;;
;res = where(toaref1[17,*] gt 0.0 and toaref1[21,*] lt 0.010)
;toaref1 = toaref1[*,res]
;---------------------------

;oplot,toaref1[0,*],toaref1[17,*] 
;plot,toaref2[0,*],toaref2[17,*]

;find matching dates
good_idx = make_array(/integer,n_elements(toaref1[0,*]))
good_idx2 = make_array(/integer,n_elements(toaref1[0,*]))

for ii=0,n_elements(toaref1[0,*])-1 do begin

res = where(abs(toaref2[0,*]-toaref1[0,ii]) lt 0.0004,count)
;good_idx1
if count eq 1 then good_idx[ii] = res
endfor

res = where(good_idx gt 0)
toaref1 = toaref1[*,res]
toaref2 = toaref2[*,good_idx[res]]
newref1 = toaref1

;get diff in reflectance
diffref = abs(toaref1[17,*]-toaref2[17,*])
rmd = make_array(n_elements(toaref1[17,*]),/float)
shiftrmd = make_array(n_elements(toaref1[17,*]),/float)
dua = make_array(n_elements(toaref1[17,*]),/float)
dayj= make_array(n_elements(toaref1[17,*]),/float)

mb= make_array(n_elements(toaref1[17,*]),/float)
dvito= make_array(n_elements(toaref1[17,*]),/float)

;plot, diffref

;recalculate dimitri ref assuming d2 on denominator
stop
for ii=0,n_elements(toaref1[0,*])-1 do begin
IF FLOAT(floor(toaref1[0,ii])) MOD 4 EQ 0 THEN DIY = 366.0 ELSE DIY = 365.0
doy = float(floor(diy*(toaref1[0,ii]-floor(toaref1[0,ii]))))
year = FLOAT(floor(toaref1[0,ii]))

;shiftdoy = doy+fix(diy/2)
;if shiftdoy gt diy then shiftdoy=shiftdoy-diy

;m = 0.9856*(doy-4.)*!DPI/180.
;phase = 0.
;rmd[ii] = 1./(1-0.01673*cos(M))

;m = 0.9856*(doy-4.)*!DPI/180.
;phase = !DPI
;shiftrmd[ii] = 1./(1-0.01673*cos(M+phase))

;d = d^4;
;
;e = 0.00014
;a = 1+e
;b = 0.01671
;c = 0.9856002831
;capd = 3.4532868
;gamma = (c*doy)-capd
;rmd[ii] = 1./(A-B*cos(gamma*!DPI/180.)-e*cos(gamma*!DPI/90.))
;
;gammasft = (c*shiftdoy)-capd
;shiftrmd[ii] = 1./(A-B*cos(gammasft*!DPI/180.)-e*cos(gammasft*!DPI/90.))

;
;
mb[ii] = (1.0+0.0167*cos(2.0*!DPI*(doy-3.0)/DIY))

;newref1[17,ii] = newref1[17,ii]/((rmd^4));*(shiftrmd^2))
;newref1[17,ii] = newref1[17,ii]/(rmd^4);*cos(newref1[3,ii]*!DTOR))
;newref1[17,ii] = newref1[17,ii]/cos(newref1[3,ii]*!DTOR)

;vito d computation
jd = 1+julday(1,1,year)-julday(1,1,1950);julian day since 1950
t = jd-10000.
dayj[ii] = t
d = ((11.786+12.190749*t) mod 360.)*(!DPI/180.)
xlp = ((134.003+0.9856*t) mod 360.)*(!DPI/180.)
dua[ii] = 1. / (1.+(1672.2*cos(xlp)+28.*cos(2.*xlp)-0.35*cos(d))*1.e-5)
dvito[ii] = dua[ii]^2

endfor

device, decomposed=0
loadct,39


;newref1[17,*] = newref1[17,*]/(mb^2)
NEWREF1[18,*] = NEWREF1[18,*]/(DVITO*(mb^2))
plot,newref1[0,*],100.*(newref1[18,*]-toaref2[18,*])/toaref2[18,*],color=90
stop


;plot,toaref1[0,*],shiftrmd
;oplot,toaref1[0,*],rmd
;plot,toaref1[0,*],rmd^2
;plot,toaref1[0,*],shiftrmd;*
;gain = abs((shiftrmd^2)-1.)+1.
;oplot,toaref1[0,*],shiftrmd^4
;plot,newref1[0,*],100.*(newref1[17,*]-toaref2[17,*])/toaref2[17,*],color=70,psym=5
;plot,toaref1[0,*],shiftrmd

;plot,toaref1[0,*],100.*(toaref1[17,*]-toaref2[17,*])/toaref2[17,*],/nodata,xtitle='Time',ytitle='100*(DIMITRI-CNES)/CNES',$
;title = 'DIMITRI/d^2_vs_CNES',background=255,color=0,yrange=[-4,2]

b = 17
newref1[b,*] = newref1[b,*]*dua^2;/rmd^2

plot,toaref1[0,*],100.*(newref1[b,*]-toaref2[b,*])/toaref2[b,*],/nodata,xtitle='Time',ytitle='100*(DIMITRI-CNES)/CNES',$
title = 'DIMITRI/d^2_vs_CNES',background=255,color=0;,yrange=[0.95,1.05]
oplot,newref1[0,*],100.*(newref1[b,*]-toaref2[b,*])/toaref2[b,*],color=90

stop

b = 17
oplot,newref1[0,*],100.*(newref1[b,*]-toaref2[b,*])/toaref2[b,*],color=90
b = 18
oplot,newref1[0,*],100.*(newref1[b,*]-toaref2[b,*])/toaref2[b,*],color=120
b = 19
oplot,newref1[0,*],100.*(newref1[b,*]-toaref2[b,*])/toaref2[b,*],color=180
b = 20
oplot,newref1[0,*],100.*(newref1[b,*]-toaref2[b,*])/toaref2[b,*],color=220

;d1 = 100.*((newref1[17,*]/(rmd^2))-toaref2[17,*])/toaref2[17,*]
;d2 = 100.*((newref1[18,*]/(rmd^2))-toaref2[18,*])/toaref2[18,*]
;oplot,newref1[0,*],d1-d2,color=220
 stop
 
 
 
oplot,toaref1[0,*],100.*(toaref1[17,*]-toaref2[17,*])/toaref2[17,*]
plot,newref1[0,*],100.*(newref1[17,*]-toaref2[17,*])/toaref2[17,*],psym=2

stop
END