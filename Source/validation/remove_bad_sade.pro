pro remove_bad_sade,site,sensor,proc_ver,prodfile

;definitions
ifol = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/'
dl = path_sep()
ouputfile = ifol+site+dl+site+'_'+sensor+'_'+Proc_ver+'_cleaned.SADE'

case sensor of
'AATSR'       : NBANDS=7 
'MERIS'       : NBANDS=15 
'MODISA'      : NBANDS=10 
'PARASOL'     : NBANDS=9 
'VEGETATION'  : NBANDS=4 
endcase

;read in sade txt
sadefile = ifol+site+dl+site+'_'+sensor+'_'+Proc_ver+'.SADE'
sadedata = read_sade_txt(sadefile,sensor)

;read in prodfile
proddata = read_sade_prodfile_text(prodfile)

;create an array of number elements of sade text
badindx = make_array(n_elements(sadedata.jpg),/integer,value=0)

;loop over each prodfile product
for ii=0,n_elements(proddata.badprod)-1 do begin

  ;  find which sadetext jpgs match, set these indeiceses to 1
  res = where(sadedata.jpg eq proddata.badprod[ii],count)
  if count gt 0 then begin
  badindx[res] = 1
  ;  delete the quicklooks
  for jj=0,count-1 do begin
    if file_test(ifol+site+dl+sensor+dl+sadedata.jpg[res[jj]]) then file_delete,ifol+site+dl+sensor+dl+sadedata.jpg[res[jj]]
    endfor
  endif

;endloop
endfor

;print out sade data from indices of 0 and not jpg file info
openw,outf,ouputfile,/get_lun
for kk=0,n_elements(sadedata.jpg)-1 do begin
if badindx[kk] then continue

for ival = 0,3 do begin
  temp = 0.0
  for iband=0,nbands-1 do begin
  temp = [temp,sadedata.(4+iband+ival*nbands)[kk]]
  endfor
  temp = temp[1:nbands]
  case ival of
  0 : toa_ref = temp 
  1 : toa_std = temp
  2 : vza = temp
  3 : vaa = temp
  endcase
  endfor

if TOA_REF[0] gt 1.0 then continue

PRINTF,OUTF,string(SENSOR+'_'+proc_ver),sadedata.ACQdate[kk],sadedata.PROCdate[kk],SITE,TOA_REF,TOA_STD,$
      VZA,VAA,sadedata.nPIXs[kk],sadedata.LAT[kk],sadedata.LON[kk],sadedata.SZA[kk],sadedata.SAA[kk],$
      FORMAT = '(4(A,1H ),'+STRTRIM(FIX(4*nBANDS),2)+'(F11.6,1H ),1(i10,1H ),2(F10.3,1H ),1(F10.6,1H ),1(f10.6))'
endfor
free_lun,outf
print, 'finished...'
end