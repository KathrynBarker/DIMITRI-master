;**************************************************************************************
;**************************************************************************************
;*
;* NAME:
;*      GET_DIMITRI_EXTRACT_TOA_NCDF_NAMES   
;* 
;* PURPOSE:
;*      THIS FUNCTION RETURNS THE HARDCODED INFORMATION FOR THE DIMITRI EXTRACTED TOA 
;*      SENSOR TIME SERIES FILES
;*
;* CALLING SEQUENCE:
;*      RES = GET_DIMITRI_EXTRACT_TOA_NCDF_NAMES()
;* 
;* INPUTS:
;*      NONE
;*
;* KEYWORDS:
;*      VERBOSE   - PROCESSING STATUS OUTPUTS
;*
;* OUTPUTS:
;*      DIM_NCDF  - A STRUCTURE CONTAINING THE HARDCODED INFORMATION
;*
;* COMMON BLOCKS:
;*      NONE
;*
;* MODIFICATION HISTORY:
;*      22 AUG 2011 - C KENT   - DIMITRI-2 V1.0
;*      23 AUG 2011 - C KENT   - UPDATED VERBOSE STATUS OUTPUTS
;*      30 AUG 2011 - C KENT   - ADDED MANUAL CLOUD SCREENING OUTPUT TO NETCDF
;*      09 MAR 2012 - C KENT   - ADDED ROI_COVER
;*
;* VALIDATION HISTORY:
;*      
;*
;**************************************************************************************
;**************************************************************************************

FUNCTION GET_DIMITRI_EXTRACT_TOA_NCDF_NAMES,VERBOSE=VERBOSE

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_EXTRACT_TOA_NCDF_NAMES: DEFINING STRUCTURE'
  DIM_NCDF = {                                                    $
              DIMPROD_STR:'n_products'                            ,$
              DIMBAND_STR:'n_bands'                               ,$
              DIMCHAR_STR:'char_length'                           ,$
              DIMCHAR_VAL:80                                      ,$
              DIMVIEW_STR:'n_views'                               ,$
              ATT_FNAME_TITLE  :'filename'                              ,$
              ATT_TOOL_TITLE   :'tool'                                  ,$
              ATT_CTIME_TITLE  :'creation_time'                         ,$
              ATT_MTIME_TITLE  :'modification_time'                     ,$
              ATT_SENSOR_TITLE :'sensor'                                ,$
              ATT_PROCV_TITLE  :'processing_version'                    ,$
              ATT_PRES_TITLE   :'pixel_resolution'                      ,$
              ATT_NBANDS_TITLE :'number_bands'                          ,$
              ATT_NDIRS_TITLE  :'number_directions'                     ,$
              ATT_SITEN_TITLE  :'site_name'                             ,$
              ATT_SITEC_TITLE  :'site_coordinates'                      ,$
              ATT_SITET_TITLE  :'site_type'                             ,$
              UNITS          :'units'                             ,$
              LONG_NAME      :'long_name'                         ,$
              UNITS_DL       :'dl'                                ,$
              UNITS_DEG      :'degrees'                           ,$
              UNITS_DATE_TIME:'yyyymmdd hh:mm:ss'                 ,$
              UNITS_DEC_TIME :'decimal year'                      ,$
              UNITS_DOBSON   :'dobson units'                      ,$
              UNITS_WVAP     :'g/cm^2'                            ,$
              UNITS_HPA      :'hectopascal (hPa)'                 ,$
              UNITS_MS       :'m/s'                               ,$
              UNITS_PCENT    :'%'                                 ,$
              VAR_PNAME_TITLE:'product_name'                      ,$
              VAR_PNAME_LONG :'Individual product filenames'      ,$
              VAR_PTIME_TITLE:'product_observation_time'          ,$
              VAR_PTIME_LONG :'Product data start times'          ,$
              VAR_DTIME_TITLE:'product_observation_decimal_time'  ,$
              VAR_DTIME_LONG :'Product data start decimal time'   ,$
              VAR_PIX_TITLE  :'n_pixels'                          ,$
              VAR_PIX_LONG   :'Number of pixels over Site'        ,$
              VAR_ROI_TITLE  :'roi_cover'                         ,$
              VAR_ROI_LONG   :'ROI fully covered'                 ,$
              VAR_RHOMU_TITLE:'site_mean'                         ,$
              VAR_RHOMU_LONG :'Mean reflectance over site'        ,$
              VAR_RHOSD_TITLE:'site_stdev'                        ,$
              VAR_RHOSD_LONG :'Standard Deviation of reflectance over site'               ,$
              VAR_CLOUD_TITLE_AUT:'cloud_fraction_auto'                                   ,$
              VAR_CLOUD_LONG_AUT :'Automated cloud screening percentage'                  ,$
              VAR_CLOUD_TITLE_MAN:'cloud_fraction_manual'                                 ,$
              VAR_CLOUD_LONG_MAN :'Manual cloud screening: not performed (-1)/clear(0)/cloudy(1)/suspect(2)'  ,$
              VAR_VZA_TITLE:'mean_viewing_zenith_angle'                                   ,$
              VAR_VZA_LONG :'Average Viewing Zenith Angle over Site'                      ,$
              VAR_VAA_TITLE:'mean_viewing_azimuth_angle'                                  ,$
              VAR_VAA_LONG :'Average Viewing Azimuth Angle over Site'                     ,$
              VAR_SZA_TITLE:'mean_solar_zenith_angle'                                     ,$
              VAR_SZA_LONG :'Average Solar Zenith Angle over Site'                        ,$
              VAR_SAA_TITLE:'mean_solar_azimuth_angle'                                    ,$
              VAR_SAA_LONG :'Average Solar Azimuth Angle over Site'                       ,$
              VAR_OZONEMU_TITLE:'ozone_column_mean'                                       ,$
              VAR_OZONEMU_LONG :'Average Ozone concentration over Site'                   ,$
              VAR_OZONESD_TITLE:'ozone_column_stdev'                                      ,$
              VAR_OZONESD_LONG :'Standard deviation of Ozone concentration over Site'     ,$
              VAR_WVAPMU_TITLE :'h2o_column_mean'                                         ,$
              VAR_WVAPMU_LONG  :'Average Water Vapour concentration over Site'            ,$
              VAR_WVAPSD_TITLE :'h2o_column_stdev'                                        ,$
              VAR_WVAPSD_LONG  :'Standard deviation of Water Vapour over Site'            ,$
              VAR_PRESSMU_TITLE:'surface_pressure_mean'                                   ,$
              VAR_PRESSMU_LONG :'Average Surface Pressure over Site'                      ,$
              VAR_PRESSSD_TITLE:'surface_pressure_stdev'                                  ,$
              VAR_PRESSSD_LONG :'Standard deviation of Surface Pressure over Site'        ,$
              VAR_RHUMMU_TITLE :'relative_humidity_mean'                                  ,$
              VAR_RHUMMU_LONG  :'Average Relative Humidity over Site'                     ,$
              VAR_RHUMSD_TITLE :'relative_humidity_stdev'                                 ,$
              VAR_RHUMSD_LONG  :'Standard deviation of Relative Humidity over Site'       ,$
              VAR_ZONALMU_TITLE:'wind_zonal_mean'                                         ,$
              VAR_ZONALMU_LONG :'Average Wind in Zonal direction (East/West) over Site'   ,$
              VAR_ZONALSD_TITLE:'wind_zonal_stdev'                                        ,$
              VAR_ZONALSD_LONG :'Standard deviation of Zonal direction (East/West) over Site'                       ,$
              VAR_MERIDMU_TITLE:'wind_meridional_mean'                                                              ,$
              VAR_MERIDMU_LONG :'Average Wind speed in Meridional direction (North/South) over Site'                ,$
              VAR_MERIDSD_TITLE:'wind_meridional_stdev'                                                             ,$
              VAR_MERIDSD_LONG :'Standard deviation of Wind speed in Meridional direction (North/South) over Site'  }

  IF KEYWORD_SET(VERBOSE) THEN PRINT,'GET_DIMITRI_EXTRACT_TOA_NCDF_NAMES: RETURNING STRUCTURE'
  RETURN,DIM_NCDF

END
