PRO VALIDATE_doublet

case strupcase(!version.os_family) of
'WINDOWS':OUTPUT_FOLDER = 'Z:\DIMITRI_code\DIMITRI_2.0\Output\doublet_validation\'
'UNIX':OUTPUT_FOLDER = '/mnt/MEREMSII/DIMITRI/20120305/DIMITRI_2.0/Output/
endcase
 
OUTPUT_FOLDER = get_dimitri_location('OUTPUT')
  dl = PATH_SEP() 
 OUTPUT_FOLDER = OUTPUT_FOLDER+'sade_validation'+dl
ED_REGION = 'Libya4'
SENSOR1 = 'PARASOL'
PROC_VER1 = 'Calibration_1'
SENSOR2 = 'VEGETATION'
PROC_VER2 = 'Calibration_1'
AMC_THRESHOLD = 10.0
DAY_OFFSET = 5.0
CLOUD_PERCENTAGE = 0.0
ROI_PERCENTAGE = 100.0 ;60% for MODISA over domeC, 80 over libya4 and , 90 for all others - ignore this and set it to 100%
VZA_MIN = 0. 
VZA_MAX = 90.
VAA_MIN = 0.
VAA_MAX = 360.
SZA_MIN = 0.
SZA_MAX = 90.
SAA_MIN = 0.
SAA_MAX = 360.
fol = '/mnt/Projects/MEREMSII/WG_Reference_Dataset/distributable_files/Libya4/'
sade1 = fol+'Libya4_MERIS_2nd_Reprocessing.SADE'
sade2 = fol+'Libya4_AATSR_2nd_Reprocessing.SADE'


;RES = DIMITRI_INTERFACE_DOUBLET(OUTPUT_FOLDER,ED_REGION,SENSOR1,PROC_VER1,SENSOR2,PROC_VER2,CHI_THRESHOLD,$
;                                   DAY_OFFSET,CLOUD_PERCENTAGE,ROI_PERCENTAGE,/VERBOSE)
;RES = EXTRACT_DOUBLETS(Output_FOLDER,ED_REGION,SENSOR1,PROC_VER1,SENSOR2,PROC_VER2,AMC_THRESHOLD,$
;                          DAY_OFFSET,CLOUD_PERCENTAGE,ROI_PERCENTAGE,                         $
;                          VZA_MIN,VZA_MAX,VAA_MIN,VAA_MAX,SZA_MIN,SZA_MAX,SAA_MIN,SAA_MAX,sade1=sade1,sade2=sade2)
RES = EXTRACT_DOUBLETS(Output_FOLDER,ED_REGION,SENSOR1,PROC_VER1,SENSOR2,PROC_VER2,AMC_THRESHOLD,$
                          DAY_OFFSET,CLOUD_PERCENTAGE,ROI_PERCENTAGE,                         $
                          VZA_MIN,VZA_MAX,VAA_MIN,VAA_MAX,SZA_MIN,SZA_MAX,SAA_MIN,SAA_MAX,/sadeoutput)

print, res
END