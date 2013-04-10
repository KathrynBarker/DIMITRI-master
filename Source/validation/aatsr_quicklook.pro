pro aatsr_quicklook

res = file_search('/mnt/Projects/MEREMSII/temp_data','*.N1')

short = strmid(res,0,87)

for ii=0,n_elements(res)-1 do begin

;if not file_test(res[ii]) then continue

;copy = where(short eq short[ii],cc)

;if cc gt 0 then for ll=1,n_elements(copy)-1 do if file_test(res[copy[ll]]) then file_delete,res[copy[ll]]
tt = GET_AATSR_QUICKLOOK(res[ii],/RGB)

endfor


end