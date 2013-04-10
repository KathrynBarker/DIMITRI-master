pro batch_ingest
batch_ingest_aatsr
batch_ingest_meris
batch_ingest_modisa
batch_ingest_vgt
end

;pro batch_ingest_2
;
;;wait,11000
;;batch_ingest_vgt
;;top
;batch_ingest_meris
;
;end

; [Amazon,BOUSSOLE,Lybia,Dome_C'SIO','SPG']

pro batch_ingest_meris

bi_time = systime()

tregions = ['Amazon','BOUSSOLE','DomeC','Libya4', 'SIO','SPG','TuzGolu','Uyuni']
tproc = ['3rd_Reprocessing']
years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
years = ['2009','2010','2011','2012']
for bb = 0,n_elements(tproc)-1 do begin
for cc = 0,N_elements(tregions)-1 do begin
for dd = 0,n_elements(years)-1 do begin
RES = DIMITRI_INTERFACE_INGEST(tregions[cc],'MERIS',tproc[bb],$
       COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400,year=years[dd])
endfor
endfor
endfor

print,'Start: ',bi_time
print,'End:   ',systime()

end

pro batch_ingest_parasol

bi_time = systime()

tregions = ['DomeC','Libya4', 'SIO','SPG','TuzGolu','Uyuni']
tproc = ['Calibration_1']
years = ['2005','2006','2007','2008','2009','2010','2011']

for bb = 0,n_elements(tproc)-1 do begin
;bb = 0
for cc = 0,N_elements(tregions)-1 do begin
for dd = 0,n_elements(years)-1 do begin
RES = DIMITRI_INTERFACE_INGEST(tregions[cc],'PARASOL',tproc[bb],COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400,year=years[dd])
endfor
endfor
endfor

print,'Start: ',bi_time
print,'End:   ',systime()

end

pro batch_ingest_modisa

bi_time = systime()
tregions = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
tproc = ['Collection_5']
years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
years = ['2011','2012']
for bb = 0,n_elements(tproc)-1 do begin
for cc = 0,N_elements(tregions)-1 do begin
for dd = 0,n_elements(years)-1 do begin
RES = DIMITRI_INTERFACE_INGEST(tregions[cc],'MODISA',tproc[bb],$
       COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400,verbose=verbose,year=years[dd])

endfor
endfor
endfor

print,'Start: ',bi_time
print,'End:   ',systime()

end
;
pro batch_ingest_aatsr

bi_time = systime()

tregions = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
tproc = ['2nd_Reprocessing']
;years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
years = ['2011','2012']
for bb = 0,n_elements(tproc)-1 do begin
;bb = 0
for cc = 0,N_elements(tregions)-1 do begin
for dd = 0,n_elements(years)-1 do begin
RES = DIMITRI_INTERFACE_INGEST(tregions[cc],'AATSR',tproc[bb],COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400,year=years[dd])
endfor
endfor
endfor

print,'Start: ',bi_time
print,'End:   ',systime()

end

;pro batch_ingest_redo
;
;;RES = DIMITRI_INTERFACE_INGEST('Amazon','AATSR','Reprocessing_2007',$
;;       COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400)
;
;RES = DIMITRI_INTERFACE_INGEST('Uyuni','PARASOL','Calibration_1',$
;       COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400)
;end

pro batch_ingest_atsr2

bi_time = systime()

tregions = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
tproc = ['Reprocessing_2008']
years = ['2002','2003']
for bb = 0,n_elements(tproc)-1 do begin
;bb = 0
for cc = 0,N_elements(tregions)-1 do begin
for dd = 0,n_elements(years)-1 do begin
RES = DIMITRI_INTERFACE_INGEST(tregions[cc],'ATSR2',tproc[bb],COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400,year=years[dd])
endfor
endfor
endfor

print,'Start: ',bi_time
print,'End:   ',systime()

end

pro batch_ingest_vgt

bi_time = systime()

tregions = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','TuzGolu','Uyuni']
tproc = ['Calibration_1']
;years = ['2002','2003','2004','2005','2006','2007','2008','2009','2010','2011']
years = ['2012']

for bb = 0,n_elements(tproc)-1 do begin
;bb = 0
for cc = 0,N_elements(tregions)-1 do begin
for dd = 0,n_elements(years)-1 do begin
RES = DIMITRI_INTERFACE_INGEST(tregions[cc],'VEGETATION',tproc[bb],$
       COLOUR_TABLE=39,PLOT_XSIZE=700,PLOT_YSIZE=400,year=years[dd])
endfor
endfor
endfor

print,'Start: ',bi_time
print,'End:   ',systime()

end
;
;pro remove_dimitri_savs
;
;cd,current=cdir
;ifolder = 'Z:\DIMITRI_code\DIMITRI_2.0\Input'
;dl = '\'
;tregions = ['Amazon','BOUSSOLE','DomeC','Libya','SIO','SPG','TuzGolu','Uyuni']
;tproc = ['Collection_5']
;tsens = ['MODISA']
;
;for i=0,n_elements(tregions)-1 do begin
;cd, ifolder+dl+'Site_'+tregions[i]+dl+tsens[0]+dl+'Proc_'+tproc[0]
;res = file_search(tsens[0]+'_*')
;if res[0] ne '' then for j=0,n_elements(res)-1 do file_delete,res[j]
;endfor 
;cd,cdir
;end
