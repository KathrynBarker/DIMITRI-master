
pro update_netcdfs
db_file = get_dimitri_location('DATABASE')
db_template = GET_DIMITRI_TEMPLATE(1,/TEMPLATE,VERBOSE=VERBOSE)

db_data = read_ascii(db_file,template=db_template)


site = ['Amazon','BOUSSOLE','DomeC','Libya4','SIO','SPG','Uyuni','TuzGolu']
sens = ['AATSR','ATSR2','MERIS','MERIS','MODISA','PARASOL']
PROC = ['2nd_Reprocessing','Reprocessing_2008','2nd_Reprocessing','3rd_Reprocessing','Collection_5','Calibration_1']

for i=0,n_elements(site)-1 do begin
for j=0,n_elements(sens)-1 do begin


	TMPSITE = site[i]
        TMPSENS = sens[j]
        TMPPRCV = proc[j]
        IDX = WHERE(DB_DATA.REGION EQ TMPSITE AND $
                    DB_DATA.SENSOR EQ TMPSENS AND $
                    DB_DATA.PROCESSING_VERSION EQ TMPPRCV)
                    
        if idx[0] eq -1 then continue           
                    
        VARNAME = 'cloud_fraction_manual'
        N_DIRS  = SENSOR_DIRECTION_INFO(TMPSENS)
        VARDATA = FIX(DB_DATA.MANUAL_CS[IDX])
        IDX = UPDATE_DIMITRI_EXTRACT_TOA_NCDF(TMPSITE,TMPSENS,TMPPRCV,VARNAME,VARDATA,VERBOSE=VERBOSE)
        
 endfor
 endfor
 print,'end'
 end