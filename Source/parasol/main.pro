pro main

!PATH=!PATH + ':'+Expand_Path('+/home/marrabld/projects/mosaec/Source', /ALL_DIRS)

;; Test one
;; tmp = get_parasol_l1b_data('/home/marrabld/projects/mosaec/Source/Input/Site_DomeC/PARASOL/Proc_Calibration_1/2006/P3L1TBG1042150KD_s74_00_S77_00_e118_00_E130_00')

;; FOR ITER = 1, 15 DO BEGIN 
;;   tvscl, tmp.REF_765NP[ITER], ITER
;; ENDFOR

;; Test tow
;; Open a .save file and query the results

DIR = '/home/marrabld/projects/mosaec/Source/'
FILE = 'DIMITRI_V2.sav'

restore, DIR + FILE

help, DB_DATA

;;help, tmp

end
