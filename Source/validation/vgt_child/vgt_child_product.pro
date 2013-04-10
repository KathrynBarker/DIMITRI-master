pro vgt_child_product, ifolder,ofolder,dl,icoords


;is the main prog to extract vgt prodicts - will call a number of smaller routines for radiometry,aux data (eg wvap),angular data, and log file


;get latitude of parent product and find indexes of block of data for extraction
  log_file = ifolder+'0001_LOG.TXT'
  prd_geo = GET_VEGETATION_LAT_LON(LOG_FILE)

  temp_dims = size(prd_geo.lat)

;find block of pixels required for extraction
  geo_id = where( $
                prd_geo.lat le icoords[0], $
                prd_geo.lat ge icoords[1], $
                prd_geo.lon le icoords[2], $
                prd_geo.lon ge icoords[3]  $
                )
  
  if geo_id[0] eq -1 then goto,no_child
  tmpx = float(geo_id)/float(temp_dims[1])
  xcoord = fix(tmpx)
  ycoord = float(temp_dims[1])*(tmpx-float(xcoord))
  pcoords = [max(ycoord),min(ycoord),max(xcoord),min(xcoord)] ;this contsin the pixel indexes to be extracted within ROI
  gcoords = [prd_geo.lat[pcoords[0]],prd_geo.lat[pcoords[1]],prd_geo.lon[pcoords[2]],prd_geo.lon[pcoords[3]]]

; create ofolder if it doesn't exist
  if file_test(ofolder,/directory) eq 0 then file_mkdir,ofolder

;correct
;; log file
  vgt_child_log, log_file,ofolder,pcoords,gcoords


; band data
; aux data
; angular data

; frig
; saving all data to the new output folder

no_child:
end