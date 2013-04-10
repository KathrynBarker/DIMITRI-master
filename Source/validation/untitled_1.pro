
restore,'./Input/Site_libya4/MODISA/Proc_Collection_5/MODISA_TOA_REF.dat'

times = sensor_l1b_ref[0,*]
times = times[uniq(times,sort(times))]
print, sensor_l1b_ref[5+12+18,0:4]


good_id = 2*indgen(3715)+1
sensor_l1b_ref = sensor_l1b_ref[*,good_id]
save,sensor_l1b_ref,filename='./Input/Site_libya4/MODISA/Proc_Collection_5/MODISA_TOA_REF.dat'
