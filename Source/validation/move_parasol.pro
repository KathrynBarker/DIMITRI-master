PRO MOVE_PARASOL

sitel = ['domec','libya','uyuni']
sited = ['DomeC','Libya4','Uyuni']

for j=0,n_elements(sitel)-1 do begin

case strupcase(!version.os_family) of
'WINDOWS':begin
          IFOLDER = 'Z:\1_Data_Archive\data_uyuni\parasol\'
          dl = '\'
          end
'UNIX':   begin
          IFOLDER = '/mnt/USB_drive02/parasol/'+sitel[j]+'/'
          ofolder = '/mnt/USB_drive/DIMITRI/DIMITRI_2.0/Input/Site_'+sited[j]+'/PARASOL/Proc_Calibration_1/
          dl = '/'
          end
endcase

STR = 'P*KD*'
CD,IFOLDER
FILES = FILE_SEARCH(STR)

FOR I=0l,N_ELEMENTS(FILES)-1 DO BEGIN

FILE = FILES[I]
RES = GET_PARASOL_L1B_HEADER(FILE)
YEAR = STRMID(STRING(RES.DATE),0,4)
;print, 'file found for year: ',year

if not file_test(oFOLDER+YEAR,/directory) then file_mkdir,oFOLDER+YEAR

FILE_COPY,FILE,oFOLDER+YEAR+dl,/OVERWRITE
STRPUT,FILE,'L',15
FILE_COPY,FILE,oFOLDER+YEAR+dl,/OVERWRITE

ENDFOR

print, 'completed for ' ,sited[j]

endfor;loop on sites

END