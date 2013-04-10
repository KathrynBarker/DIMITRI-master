PRO PLOT_DIMITRI_RHO_STD

; NOTE, NEED TO HAVE COMPILE DIMITRI ROUTINES FOR THIS TO WORK, 
; AND IT'S ECPECTING YOU TO BE IN THE SOURCE DIRECTORY

; DEFINE SITE, SENSORS AND PROC VERSIONS TO SEARCH FOR

  SITES     = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
  SENSORS   = ['PARASOL','AATSR','ATSR2','MERIS','MERIS','MODISA']
  PROCVERS  = ['Calibration_1','2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5']
  COLOURS   = [0,70,120,160,200,254]
  IFOLDER   = GET_DIMITRI_LOCATION('INPUT')
  oFOLDER   = GET_DIMITRI_LOCATION('OUTPUT')
  DL        = GET_DIMITRI_LOCATION('DL')
  num_non_refs = 5+12

; DEFINE PLOT BASICS

  YRANGE    = [0.,.5]
  XRANGE    = [0.,1.]
  XTITLE    = 'TOA RHO (665nm)'
  YTITLE    = 'TOA STDEV (665nm)'
  LINESTYLE = -1
  PSYM      = 3
  PLOT_BASE = '_TOA_RHO_STDEV.jpg'

  LOADCT,39
  DEVICE, DECOMPOSED = 0

; LOOP OVER EACH SITE

  FOR ISITE = 0,N_ELEMENTS(SITES)-1 DO BEGIN

; CREATE A PLOT BASE

  counter=0
  PLOT, [0.],[0.],/NODATA,COLOR = 0, BACKGROUND = 255,$
    XRANGE = XRANGE, YRANGE = YRANGE,$
    XTITLE = XTITLE, YTITLE = YTITLE

;-----------------------------------------
; RETRIEVE THE SITE TYPE

  SITE_TYPE = GET_SITE_TYPE(sites[isite])

;LOOP OVER EACH SENSOR

    for isensor = 0,N_elements(sensors)-1 do begin

;IF DATA PRESENT FIND INDEX OF 665NM BAND AND GET DATA INDEXES ABOVE 0

      ifile = ifolder+'Site_'+sites[isite]+dl+sensors[isensor]+dl+'Proc_'+procvers[isensor]+dl+sensors[isensor]+'_TOA_REF.dat'
      if file_test(ifile) eq 0 then continue

      IF sensors[isensor] EQ 'MODISA' THEN BEGIN
        IF STRUPCASE(SITE_TYPE) EQ 'OCEAN' THEN TEMP_SENS = 'MODISA_O' ELSE TEMP_SENS = 'MODISA_L'
      ENDIF ELSE TEMP_SENS = sensors[isensor]
      
      BID = GET_SENSOR_BAND_INDEX(TEMP_SENS,9)
      if bid lt 0 then continue

;OPLOT DATA ONTO PLOT

      restore,ifile
      tmp_dims = size(sensor_l1b_ref)
      nb_bands = (tmp_dims[1]-num_non_refs)/2
      
      rho = sensor_l1b_ref(num_non_refs+bid,*)
      std = sensor_l1b_ref(num_non_refs+nb_bands+bid,*)

      idx = where(rho gt 0.0,count)
      if count eq 0 then continue
      
      oplot,rho[idx],std[idx],color=colours[isensor],linestyle=linestyle,psym=psym
      xyouts,0.85,0.9-counter*0.035,string(strmid(sensors[isensor],0,3)+'_'+strmid(procvers[isensor],0,3)),color=colours[isensor],/normal
      counter++

;ENDLOOP ON SENSORS

    endfor

;SAVE PLOT

    image = tvrd(/true)
    write_jpeg,oFOLDER+sites[isite]+PLOT_BASE,image,/true

;ENDLOOP ON SITES
  
  endfor
  wdelete

end