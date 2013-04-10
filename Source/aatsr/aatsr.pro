; LIBRARY AATSR.PRO (c) RAL/CCLRC 2002
;
; VERSION
;     1.6  TJN  09-JAN-2002  Mend logic in AATSR_READ_HEADERS. Delete
;                            AATSR_READ_ADS_* functions. (Superceded
;                            by ENVISAT_READ_DS).
;     1.5  TJN  18-NOV-2002  Add L2 averaged product functions.
;                            Change most AATSR_DEFINE_* function
;                            names to take advantage of automatic
;                            IDL structure definitions. Expand
;                            AATSR_DEFINE_CONSTANTS to include SPH
;                            sizes for all L1 and L2 products.
;                            Update AATSR_GET_HEADERS accordingly.
;                            Add AATSR_LOC_TO_INDEX function.
;     1.4  TJN  25-OCT-2002  Add TIME option to AATSR_READ_MDS.
;     1.3  TJN  22-OCT-2002  Change DSD read in AATSR_GET_HEADERS
;                            to accomodate corrected AATSR MPH.NUM_DSD
;                            value in production files.
;     1.2  TJN  16-OCT-2002  Correct error in ENVISAT_BILINEAR
;                            calls when unwinding +/-180 boundaries.
;     1.1  TJN  11-OCT-2002  Add view angle routines, remove +/-180
;                            degree jumps in aziumth and longitude
;                            before interpolation. Change structure
;                            and routine names to correspond to the
;                            AATSR product handbook where possible.
;     TJN  1.0  02-SEP-2002  Original.
;
; DESCRIPTION
;      AARSR-specific structure prototypes and routines to ingest
;      AATSR Level 1b and L2 gridded data. A few reading routines
;      - those dealing with pixel mapping - have not yet been
;      implimented.
;
; AATSR constants and record prototypes ***************************
;



PRO AATSR_DEFINE_CONSTANTS, KEEP_DEFAULTS=KD
;
; VERSION
;     1.0  TJN  05-SEP-2002  Original
;
; DESCRIPTION
;     Program-wide definitions for constants not contained
;     in the product file.
;
; OPTIONAL PARAMETER
;     KEEP_DEFAULTS  Do not redefine AATSR default values
;
; Code starts here ------------------------------------------------
;
  DEFSYSV, '!AATSR', EXISTS=isAATSR

  SPH_Size = {AATSR_SPH_SIZES,         $
    BRW_AX      : 98,                  $
    CH1_AX      : 98,                  $
    CL1_AX      : 98,                  $
    GC1_AX      : 98,                  $
    INS_AX      : 98,                  $
    PC1_AX      : 98,                  $
    PC2_AX      : 98,                  $
    SST_AX      : 98,                  $
    VC1_AX      : 98,                  $
    NL__0P      : 836,                 $
    TOA_1P      : 2190,                $
    AR__2P      : 1315,                $
    MET_2P      : 1315,                $
    NR__2P      : 2190,                $
    AST_BP      : 2190                 $
  }

  IF KEYWORD_SET(KD) AND isAATSR       $
  THEN Default = !AATSR.DEFAULT        $
  ELSE Default = {AATSR_DEFAULTS,      $
    LENGTH      : 512,                 $
    ADS_LOC     : -999d0,              $
    ADS_SA      : -999d0,              $
    MDS         : 0L                   $
  }

  Exception = {AATSR_EXCEPTIONS,       $
    TOPOGRAPHIC : -999999L,            $
    VIEW_ANGLE  : -999000L             $
  }

  DEFSYSV, '!AATSR', {AATSR_CONSTANTS, $
    SPH_SIZE    : SPH_Size,            $  ; L1, L2 size
    NUM_LOC_TP  : 23,                  $
    NUM_SA_TP   : 11,                  $
    GRANULE     : 32,                  $
    WIDTH       : 512,                 $
    BRW_WIDTH   : 128,                 $
    DEFAULT     : Default,             $
    EXCEPTION   : Exception            $
  }
END



;******************************************************************
; Common ADS record structure definitions
;******************************************************************



PRO AATSR_ADSR_SQ__DEFINE
;
; VERSION
;     1.1  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_ADSR_SQ to take
;                            advantage of automatic structure
;                            definitions.
;     1.0  TJN  11-OCT-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for ATSR summary quality
;     Annotation Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_ADSR_SQ,                  $
    DSR_TIME             : {ENVISAT_MJD}, $
    ATTACH_FLAG          : 0B,            $
    SPARE_1              : BYTARR(3),     $
    SCAN_NUM             : 0U,            $
    PV_NAD_NULL_PAC      : 0,             $
    PV_NAD_FAIL_VAL      : 0,             $
    PV_NAD_FAIL_CRC_CHK  : 0,             $
    PV_NAD_SHOW_BUF_FULL : 0,             $
    PV_NAD_SCAN_JITT     : 0,             $
    RESV_CHAR_1          : 0,             $
    RESV_CHAR_2          : 0,             $
    RESV_CHAR_3          : 0,             $
    RESV_CHAR_4          : 0,             $
    PV_NAD_SCAN_ERROR    : 0,             $
    PV_FOR_NULL_PAC      : 0,             $
    PV_FOR_FAIL_VAL      : 0,             $
    PV_FOR_FAIL_CRC_CHK  : 0,             $
    PV_FOR_SHOW_BUF_FULL : 0,             $
    PV_FOR_SCAN_JITT     : 0,             $
    RESV_CHAR_5          : 0,             $
    RESV_CHAR_6          : 0,             $
    RESV_CHAR_7          : 0,             $
    RESV_CHAR_8          : 0,             $
    PV_FOR_SCAN_ERROR    : 0,             $
    SPARE_2              : BYTARR(28)     $
  }
END



PRO AATSR_ADSR_LOC__DEFINE
;
; VERSION
;     1.2  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_ADSR_LOC to take
;                            advantage of automatic structure
;                            definitions.
;     1.1  TJN  02-OCT-2002  Use AATSR product handbook tag names.
;     1.0  TJN  05-SEP-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for ATSR grid pixel latitude
;     and longtitude topographic corrections Annotation Data Set
;     Record.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_ADSR_LOC,                       $
    DSR_TIME       : {ENVISAT_MJD},             $
    ATTACH_FLAG    : 0B,                        $
    SPARE_1        : BYTARR(3),                 $
    IMAG_SCAN_Y    : 0L,                        $
    TIE_PT_LAT     : LONARR(!AATSR.NUM_LOC_TP), $
    TIE_PT_LONG    : LONARR(!AATSR.NUM_LOC_TP), $
    LAT_CORR_NADV  : LONARR(!AATSR.NUM_LOC_TP), $
    LONG_CORR_NADV : LONARR(!AATSR.NUM_LOC_TP), $
    LAT_CORR_FORV  : LONARR(!AATSR.NUM_LOC_TP), $
    LONG_CORR_FORV : LONARR(!AATSR.NUM_LOC_TP), $
    TOPO_ALT       : INTARR(!AATSR.NUM_LOC_TP), $
    SPARE_2        : BYTARR(8)                  $
  }
END



PRO AATSR_ADSR_SCAN__DEFINE
;
; VERSION
;     1.1  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_ADSR_SCAN to take
;                            advantage of automatic structure
;                            definitions.
;     1.0  TJN  11-OCT-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for AATSR scan pixel x and y
;     Annotation Data Set Record.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_ADSR_SCAN,         $
    DSR_TIME      : {ENVISAT_MJD}, $
    ATTACH_FLAG   : 0B,            $
    SPARE_1       : BYTARR(3),     $
    INST_SCAN_NUM : 0U,            $
    TIE_PIX_X     : LONARR(99),    $
    TIE_PIX_Y     : LONARR(99),    $
    SPARE_2       : BYTARR(20)     $
  }
END



PRO AATSR_ADSR_SA__DEFINE
;
; VERSION
;     1.1  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_ADSR_SA to take
;                            advantage of automatic structure
;                            definitions.
;     1.0  TJN  11-OCT-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for grid pixel solar angles
;     Annotation Data Set Record.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_ADSR_SA,                      $
    DSR_TIME      : {ENVISAT_MJD},            $
    ATTACH_FLAG   : 0B,                       $
    SPARE_1       : BYTARR(3),                $
    IMG_SCAN_Y    : 0L,                       $
    TIE_PT_SOL_EL : LONARR(!AATSR.NUM_SA_TP), $
    TIE_PT_SAT_EL : LONARR(!AATSR.NUM_SA_TP), $
    TIE_PT_SOL_AZ : LONARR(!AATSR.NUM_SA_TP), $
    TIE_PT_SAT_AZ : LONARR(!AATSR.NUM_SA_TP), $
    SPARE_2       : BYTARR(20)                $
  }
END



PRO AATSR_ADSR_PIX__DEFINE
;
; VERSION
;     1.1  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_ADSR_PIX to take
;                            advantage of automatic structure
;                            definitions.
;     1.0  TJN  11-OCT-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for AATSR scan and pixel
;     number Annotation Data Set Record.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_ADSR_PIX,                  $
    DSR_TIME      : {ENVISAT_MJD},         $
    ATTACH_FLAG   : 0B,                    $
    SPARE_1       : BYTARR(3),             $
    IMG_SCAN_Y    : 0L,                    $
    INST_SCAN_NUM : UINTARR(!AATSR.WIDTH), $
    PIX_NUM       : UINTARR(!AATSR.WIDTH)  $
  }
END



;******************************************************************
; TOA_1P MDS record structure definition
;******************************************************************



PRO AATSR_MDSR_1P__DEFINE
;
; VERSION
;     1.2  TJN  09-JAN-2003  Rename to AATSR_MDSR_1P_DEFINE
;     1.1  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_MDSR to take advantage of
;                            automatic structure definitions.
;     1.0  TJN  05-SEP-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for all Data Set Records
;     found in AATSR Level 1 Measurement Data Sets, MDS #1 - #18.
;     Signed or unsigned values are selected by AATSR_READ_MDS at
;     read time.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_1P,                 $
    DSR_TIME     : {ENVISAT_MJD},        $
    QUALITY_FLAG : 0B,                   $
    SPARE_1      : BYTARR(3),            $
    IMG_SCAN_Y   : 0L,                   $
    VALUE        : UINTARR(!AATSR.WIDTH) $ ; FIX to INT for
  }                                        ; 1P_MDSR_BT_* products
END



;******************************************************************
; AR__2P MDS record structure definitions
;******************************************************************



PRO AATSR_MDSR_SR_SMALL__DEFINE
;
; VERSION
;     1.0  TJN  15-NOV-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 10arcmin and
;     17km BT/TOA sea record Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_SR_SMALL,          $
    DSR_TIME           : {ENVISAT_MJD}, $
    QUALITY_FLAG       : 1B,            $
    SPARE_1            : BYTARR(3),     $
    LAT                : 0L,            $
    LON                : 0L,            $
    M_ACTRK_PIX_NUM    : 0,             $
    PIX_NAD            : 0,             $

    PIX_SS_NAD         : 0,             $
    PERC_CL_PIX_SS_NAD : 0,             $

    SA_12BT_CLR_NAD    : 0L,            $
    SA_11BT_CLR_NAD    : 0L,            $
    SA_37BT_CLR_NAD    : 0L,            $
    SA_16TOA_CLR_NAD   : 0,             $
    SA_87TOA_CLR_NAD   : 0,             $
    SA_67TOA_CLR_NAD   : 0,             $
    SA_55TOA_CLR_NAD   : 0,             $
    SA_12BT_CL_NAD     : 0L,            $
    SA_11BT_CL_NAD     : 0L,            $
    SA_37BT_CL_NAD     : 0L,            $
    SA_16TOA_CL_NAD    : 0,             $
    SA_87TOA_CL_NAD    : 0,             $
    SA_67TOA_CL_NAD    : 0,             $
    SA_55TOA_CL_NAD    : 0,             $

    FAIL_FLAG_NAD      : 0U,            $

    PIX_FOR            : 0,             $
    PIX_SS_FOR         : 0,             $
    PERC_CL_PIX_SS_FOR : 0,             $

    SA_12BT_CLR_FOR    : 0L,            $
    SA_11BT_CLR_FOR    : 0L,            $
    SA_37BT_CLR_FOR    : 0L,            $
    SA_16TOA_CLR_FOR   : 0,             $
    SA_87TOA_CLR_FOR   : 0,             $
    SA_67TOA_CLR_FOR   : 0,             $
    SA_55TOA_CLR_FOR   : 0,             $
    SA_12BT_CL_FOR     : 0L,            $
    SA_11BT_CL_FOR     : 0L,            $
    SA_37BT_CL_FOR     : 0L,            $
    SA_16TOA_CL_FOR    : 0,             $
    SA_87TOA_CL_FOR    : 0,             $
    SA_67TOA_CL_FOR    : 0,             $
    SA_55TOA_CL_FOR    : 0,             $

    FAIL_FLAG_FOR      : 0U             $
  }
END



PRO AATSR_MDSR_SR_LARGE__DEFINE
;
; VERSION
;     1.0  TJN  15-NOV-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 30arcmin and
;     50km BT/TOA sea record Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_SR_LARGE,          $
    DSR_TIME           : {ENVISAT_MJD}, $
    QUALITY_FLAG       : 1B,            $
    SPARE_1            : BYTARR(3),     $
    LAT                : 0L,            $
    LON                : 0L,            $
    M_ACTRK_PIX_NUM    : 0,             $

    PIX_NAD            : 0,             $
    PIX_SS_NAD         : 0,             $
    PERC_CL_PIX_SS_NAD : 0,             $

    SA_12BT_CLR_NAD    : 0L,            $
    SD_12BT_CLR_NAD    : 0L,            $
    SA_11BT_CLR_NAD    : 0L,            $
    SD_11BT_CLR_NAD    : 0L,            $
    SA_37BT_CLR_NAD    : 0L,            $
    SD_37BT_CLR_NAD    : 0L,            $
    SA_16TOA_CLR_NAD   : 0,             $
    SD_16TOA_CLR_NAD   : 0,             $
    SA_87TOA_CLR_NAD   : 0,             $
    SD_87TOA_CLR_NAD   : 0,             $
    SA_67TOA_CLR_NAD   : 0,             $
    SD_67TOA_CLR_NAD   : 0,             $
    SA_55TOA_CLR_NAD   : 0,             $
    SD_55TOA_CLR_NAD   : 0,             $

    SA_12BT_CL_NAD     : 0L,            $
    SD_12BT_CL_NAD     : 0L,            $
    SA_11BT_CL_NAD     : 0L,            $
    SD_11BT_CL_NAD     : 0L,            $
    SA_37BT_CL_NAD     : 0L,            $
    SD_37BT_CL_NAD     : 0L,            $
    SA_16TOA_CL_NAD    : 0,             $
    SD_16TOA_CL_NAD    : 0,             $
    SA_87TOA_CL_NAD    : 0,             $
    SD_87TOA_CL_NAD    : 0,             $
    SA_67TOA_CL_NAD    : 0,             $
    SD_67TOA_CL_NAD    : 0,             $
    SA_55TOA_CL_NAD    : 0,             $
    SD_55TOA_CL_NAD    : 0,             $

    FAIL_FLAG_NAD      : 0U,            $

    PIX_FOR            : 0,             $
    PIX_SS_FOR         : 0,             $
    PERC_CL_PIX_SS_FOR : 0,             $

    SA_12BT_CLR_FOR    : 0L,            $
    SD_12BT_CLR_FOR    : 0L,            $
    SA_11BT_CLR_FOR    : 0L,            $
    SD_11BT_CLR_FOR    : 0L,            $
    SA_37BT_CLR_FOR    : 0L,            $
    SD_37BT_CLR_FOR    : 0L,            $
    SA_16TOA_CLR_FOR   : 0,             $
    SD_16TOA_CLR_FOR   : 0,             $
    SA_87TOA_CLR_FOR   : 0,             $
    SD_87TOA_CLR_FOR   : 0,             $
    SA_67TOA_CLR_FOR   : 0,             $
    SD_67TOA_CLR_FOR   : 0,             $
    SA_55TOA_CLR_FOR   : 0,             $
    SD_55TOA_CLR_FOR   : 0,             $

    SA_12BT_CL_FOR     : 0L,            $
    SD_12BT_CL_FOR     : 0L,            $
    SA_11BT_CL_FOR     : 0L,            $
    SD_11BT_CL_FOR     : 0L,            $
    SA_37BT_CL_FOR     : 0L,            $
    SD_37BT_CL_FOR     : 0L,            $
    SA_16TOA_CL_FOR    : 0,             $
    SD_16TOA_CL_FOR    : 0,             $
    SA_87TOA_CL_FOR    : 0,             $
    SD_87TOA_CL_FOR    : 0,             $
    SA_67TOA_CL_FOR    : 0,             $
    SD_67TOA_CL_FOR    : 0,             $
    SA_55TOA_CL_FOR    : 0,             $
    SD_55TOA_CL_FOR    : 0,             $

    FAIL_FLAG_FOR      : 0U,            $

    PIX_NSIG_NAD       : 0,             $
    PIX_SS             : 0,             $

    LOW_11BT_CL_NAD    : 0,             $
    CORR_12BT_NAD      : 0,             $
    CORR_37BT_NAD      : 0,             $
    CORR_16REF_NAD     : 0,             $
    CORR_87REF_NAD     : 0,             $
    CORR_67REF_NAD     : 0,             $
    CORR_55REF_NAD     : 0,             $

    LOW_11BT_CL_FOR    : 0,             $
    CORR_12BT_FOR      : 0,             $
    CORR_37BT_FOR      : 0,             $
    CORR_16REF_FOR     : 0,             $
    CORR_87REF_FOR     : 0,             $
    CORR_67REF_FOR     : 0,             $
    CORR_55REF_FOR     : 0              $
  }
END



PRO AATSR_MDSR_LR_SMALL__DEFINE
;
; VERSION
;     1.0  TJN  09-JAN-2003  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 10arcmin and
;     17km BT/TOA land record Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_LR_SMALL,          $
    DSR_TIME           : {ENVISAT_MJD}, $
    QUALITY_FLAG       : 1B,            $
    SPARE_1            : BYTARR(3),     $
    LAT                : 0L,            $
    LON                : 0L,            $
    M_ACTRK_PIX_NUM    : 0,             $
    PIX_NAD            : 0,             $

    PIX_LS_NAD         : 0,             $
    PERC_CL_PIX_LS_NAD : 0,             $
    LAT_CORR_NAD       : 0L,            $
    LONG_CORR_NAD      : 0L,            $

    SA_12BT_CLR_NAD    : 0L,            $
    SA_11BT_CLR_NAD    : 0L,            $
    SA_37BT_CLR_NAD    : 0L,            $
    SA_16TOA_CLR_NAD   : 0,             $
    SA_87TOA_CLR_NAD   : 0,             $
    SA_67TOA_CLR_NAD   : 0,             $
    SA_55TOA_CLR_NAD   : 0,             $
    SA_12BT_CL_NAD     : 0L,            $
    SA_11BT_CL_NAD     : 0L,            $
    SA_37BT_CL_NAD     : 0L,            $
    SA_16TOA_CL_NAD    : 0,             $
    SA_87TOA_CL_NAD    : 0,             $
    SA_67TOA_CL_NAD    : 0,             $
    SA_55TOA_CL_NAD    : 0,             $

    FAIL_FLAG_NAD      : 0U,            $

    PIX_FOR            : 0,             $
    PIX_LS_FOR         : 0,             $
    PERC_CL_PIX_LS_FOR : 0,             $
    LAT_CORR_FOR       : 0L,            $
    LONG_CORR_FOR      : 0L,            $

    SA_12BT_CLR_FOR    : 0L,            $
    SA_11BT_CLR_FOR    : 0L,            $
    SA_37BT_CLR_FOR    : 0L,            $
    SA_16TOA_CLR_FOR   : 0,             $
    SA_87TOA_CLR_FOR   : 0,             $
    SA_67TOA_CLR_FOR   : 0,             $
    SA_55TOA_CLR_FOR   : 0,             $
    SA_12BT_CL_FOR     : 0L,            $
    SA_11BT_CL_FOR     : 0L,            $
    SA_37BT_CL_FOR     : 0L,            $
    SA_16TOA_CL_FOR    : 0,             $
    SA_87TOA_CL_FOR    : 0,             $
    SA_67TOA_CL_FOR    : 0,             $
    SA_55TOA_CL_FOR    : 0,             $

    FAIL_FLAG_FOR      : 0U             $
  }
END



PRO AATSR_MDSR_LR_LARGE__DEFINE
;
; VERSION
;     1.0  TJN  09-JAN-2003  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 30arcmin and
;     50km BT/TOA land record Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_LR_LARGE,          $
    DSR_TIME           : {ENVISAT_MJD}, $
    QUALITY_FLAG       : 1B,            $
    SPARE_1            : BYTARR(3),     $
    LAT                : 0L,            $
    LON                : 0L,            $
    M_ACTRK_PIX_NUM    : 0,             $

    PIX_NAD            : 0,             $
    PIX_LS_NAD         : 0,             $
    PERC_CL_PIX_LS_NAD : 0,             $
    LAT_CORR_NAD       : 0L,            $
    LONG_CORR_NAD      : 0L,            $

    SA_12BT_CLR_NAD    : 0L,            $
    SD_12BT_CLR_NAD    : 0L,            $
    SA_11BT_CLR_NAD    : 0L,            $
    SD_11BT_CLR_NAD    : 0L,            $
    SA_37BT_CLR_NAD    : 0L,            $
    SD_37BT_CLR_NAD    : 0L,            $
    SA_16TOA_CLR_NAD   : 0,             $
    SD_16TOA_CLR_NAD   : 0,             $
    SA_87TOA_CLR_NAD   : 0,             $
    SD_87TOA_CLR_NAD   : 0,             $
    SA_67TOA_CLR_NAD   : 0,             $
    SD_67TOA_CLR_NAD   : 0,             $
    SA_55TOA_CLR_NAD   : 0,             $
    SD_55TOA_CLR_NAD   : 0,             $

    SA_12BT_CL_NAD     : 0L,            $
    SD_12BT_CL_NAD     : 0L,            $
    SA_11BT_CL_NAD     : 0L,            $
    SD_11BT_CL_NAD     : 0L,            $
    SA_37BT_CL_NAD     : 0L,            $
    SD_37BT_CL_NAD     : 0L,            $
    SA_16TOA_CL_NAD    : 0,             $
    SD_16TOA_CL_NAD    : 0,             $
    SA_87TOA_CL_NAD    : 0,             $
    SD_87TOA_CL_NAD    : 0,             $
    SA_67TOA_CL_NAD    : 0,             $
    SD_67TOA_CL_NAD    : 0,             $
    SA_55TOA_CL_NAD    : 0,             $
    SD_55TOA_CL_NAD    : 0,             $

    FAIL_FLAG_NAD      : 0U,            $

    PIX_FOR            : 0,             $
    PIX_SS_FOR         : 0,             $
    PERC_CL_PIX_SS_FOR : 0,             $
    LAT_CORR_FOR       : 0L,            $
    LONG_CORR_FOR      : 0L,            $

    SA_12BT_CLR_FOR    : 0L,            $
    SD_12BT_CLR_FOR    : 0L,            $
    SA_11BT_CLR_FOR    : 0L,            $
    SD_11BT_CLR_FOR    : 0L,            $
    SA_37BT_CLR_FOR    : 0L,            $
    SD_37BT_CLR_FOR    : 0L,            $
    SA_16TOA_CLR_FOR   : 0,             $
    SD_16TOA_CLR_FOR   : 0,             $
    SA_87TOA_CLR_FOR   : 0,             $
    SD_87TOA_CLR_FOR   : 0,             $
    SA_67TOA_CLR_FOR   : 0,             $
    SD_67TOA_CLR_FOR   : 0,             $
    SA_55TOA_CLR_FOR   : 0,             $
    SD_55TOA_CLR_FOR   : 0,             $

    SA_12BT_CL_FOR     : 0L,            $
    SD_12BT_CL_FOR     : 0L,            $
    SA_11BT_CL_FOR     : 0L,            $
    SD_11BT_CL_FOR     : 0L,            $
    SA_37BT_CL_FOR     : 0L,            $
    SD_37BT_CL_FOR     : 0L,            $
    SA_16TOA_CL_FOR    : 0,             $
    SD_16TOA_CL_FOR    : 0,             $
    SA_87TOA_CL_FOR    : 0,             $
    SD_87TOA_CL_FOR    : 0,             $
    SA_67TOA_CL_FOR    : 0,             $
    SD_67TOA_CL_FOR    : 0,             $
    SA_55TOA_CL_FOR    : 0,             $
    SD_55TOA_CL_FOR    : 0,             $

    FAIL_FLAG_FOR      : 0U,            $

    PIX_NSIG_NAD       : 0,             $
    PIX_LS             : 0,             $

    LOW_11BT_CL_NAD    : 0,             $
    CORR_12BT_NAD      : 0,             $
    CORR_37BT_NAD      : 0,             $
    CORR_16REF_NAD     : 0,             $
    CORR_87REF_NAD     : 0,             $
    CORR_67REF_NAD     : 0,             $
    CORR_55REF_NAD     : 0,             $

    LOW_11BT_CL_FOR    : 0,             $
    CORR_12BT_FOR      : 0,             $
    CORR_37BT_FOR      : 0,             $
    CORR_16REF_FOR     : 0,             $
    CORR_87REF_FOR     : 0,             $
    CORR_67REF_FOR     : 0,             $
    CORR_55REF_FOR     : 0              $
  }
END



PRO AATSR_MDSR_SST_SMALL__DEFINE
;
; VERSION
;     1.0  TJN  15-NOV-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 10arcmin and
;     17km SST Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_SST_SMALL,      $
    DSR_TIME        : {ENVISAT_MJD}, $
    QUALITY_FLAG    : 1B,            $
    SPARE_1         : BYTARR(3),     $
    LAT             : 0L,            $
    LON             : 0L,            $
    M_ACTRK_PIX_NUM : 0,             $
    M_NAD           : 0,             $
    PIX_NAD         : 0U,            $
    M_DUAL_VW       : 0,             $
    PIX_DUAL_VW     : 0U,            $
    AST_CONF_FLAGS  : 0UL            $
  }
END



PRO AATSR_MDSR_SST_LARGE__DEFINE
;
; VERSION
;     1.0  TJN  15-NOV-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 30arcmin and
;     50km Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_SST_LARGE,      $
    DSR_TIME        : {ENVISAT_MJD}, $
    QUALITY_FLAG    : 1B,            $
    SPARE_1         : BYTARR(3),     $
    LAT             : 0L,            $
    LON             : 0L,            $
    M_ACTRK_PIX_NUM : 0,             $
    M_NAD           : 0,             $
    SD_NAD          : 0,             $
    PIX_NAD         : 0U,            $
    M_DUAL_VW       : 0,             $
    SD_DUAL_VW      : 0,             $
    PIX_DUAL_VW     : 0U,            $
    AST_CONF_FLAGS  : 0UL,           $
    CL_TOP_TEMP_NAD : 0,             $
    PERC_CL_COV_NAD : 0,             $
    CL_TOP_TEMP_FOR : 0,             $
    PERC_CL_COV_FOR : 0              $
  }
END




PRO AATSR_GADS_VCC__DEFINE
;
; VERSION
;     1.1  TJN  15-NOV-2002  Change function name from
;                            AATSR_DEFINE_GADS_VCC to take
;                            advantage of automatic structure
;                            definitions.
;     1.0  TJN  11-OCT-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for AATSR scan pixel x and y
;     Global Annotation Data Set.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_GADS_VCC,            $
    DSR_TIME        : {ENVISAT_MJD}, $
    ATTACH_FLAG     : 0B,            $
    SPARE_1         : BYTARR(3),     $
    SLP_16_MIC      : 0.,            $
    SLP_087_MIC     : 0.,            $
    SLP_067_MIC     : 0.,            $
    SLP_055_MIC     : 0.,            $
    ASC_TIME        : {ENVISAT_MJD}, $
    AV_MON_CNT      : 0.,            $
    SD_MON_CNT      : 0.,            $
    SOL_IRR_16      : 0.,            $
    SOL_IRR_087     : 0.,            $
    SOL_IRR_067     : 0.,            $
    SOL_IRR_055     : 0.,            $
    AVE_VISPIX_16   : 0.,            $
    AVE_VISPIX_087  : 0.,            $
    AVE_VISPIX_067  : 0.,            $
    AVE_VISPIX_055  : 0.,            $
    VIS_PIXNOIS_16  : 0.,            $
    VIS_PIXNOIS_087 : 0.,            $
    VIS_PIXNOIS_067 : 0.,            $
    VIS_PIXNOIS_055 : 0.,            $
    AVE_XBB_CNT_16  : 0.,            $
    AVE_XBB_CNT_087 : 0.,            $
    AVE_XBB_CNT_067 : 0.,            $
    AVE_XBB_CNT_055 : 0.,            $
    XBB_NOIS_16     : 0.,            $
    XBB_NOIS_087    : 0.,            $
    XBB_NOIS_067    : 0.,            $
    XBB_NOIS_055    : 0.,            $
    PARITY_CHAR     : 0,             $
    SPARE_2         : BYTARR(20)     $
  }
END



;******************************************************************
; MET_2P MDS record structure definition
;******************************************************************



PRO AATSR_MDSR_MUP__DEFINE
;
; VERSION
;     1.0  TJN  19-NOV-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 Meteo User
;     Product Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_MUP,               $
    DSR_TIME           : {ENVISAT_MJD}, $
    REC_QUA_IND        : 1B,            $
    SPARE_1            : BYTARR(3),     $
    LAT                : 0L,            $
    LON                : 0L,            $
    SA_12BT_CLR_NAD    : 0L,            $
    SA_11BT_CLR_NAD    : 0L,            $
    SA_37BT_CLR_NAD    : 0L,            $
    SA_12BT_CLR_FOR    : 0L,            $
    SA_11BT_CLR_FOR    : 0L,            $
    SA_37BT_CLR_FOR    : 0L,            $
    M_ACTRK_PIX_NUM    : 0,             $
    M_NAD              : 0,             $
    PIX_NAD            : 0U,            $
    M_DUAL_VW          : 0,             $
    PIX_DUAL_VW        : 0U,            $
    AST_CONF_FLAGS     : 0UL            $
  }
END



;******************************************************************
; NR__2P MDS record structure definition
;******************************************************************



PRO AATSR_MDSR_DP__DEFINE
;
; VERSION
;     1.0  TJN  15-NOV-2002  Original.
;
; DESCRIPTION
;     Generates a structure prototype for AATSR L2 distributed
;     product Measurement Data Set Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_DP,                   $
    DSR_TIME      : {ENVISAT_MJD},         $
    QUALITY_FLAG  : 1B,                    $
    SPARE_1       : BYTARR(3),             $
    IMAG_SCAN_Y   : 0L,                    $
    CONF_WD_FLAGS : UINTARR(!AATSR.WIDTH), $
    NAD_FIELD     : INTARR(!AATSR.WIDTH),  $
    COMB_FIELD    : INTARR(!AATSR.WIDTH)   $
  }
END




;******************************************************************
; AST_BP MDS record structure definition
;******************************************************************



PRO AATSR_RGB__DEFINE
;
; VERSION
;     1.0  TJN  15-NOV-2002  Original.
;
; DESCRIPTION
;     Generates RGB structure for browse product.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_RGB, $
    RED   : 0B,      $
    GREEN : 0B,      $
    BLUE  : 0B       $
  }
END



;PRO AATSR_RGB__DEFINE
PRO AATSR_MDSR_BRW__DEFINE;ADDED BY C.KENT ON 20/10/2010
;
; VERSION
;     1.0  TJN  05-SEP-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for browse product Data Set
;     Records.
;
; Code starts here ------------------------------------------------
;
  Temp = {AATSR_MDSR_BRW,                                   $
    DSR_TIME     : {ENVISAT_MJD},                           $
    QUALITY_FLAG : 0B,                                      $
    SPARE_1      : BYTARR(3),                               $
    IMG_SCAN_Y   : 0L,                                      $
    RGB_PIX      : REPLICATE({AATSR_RGB}, !AATSR.BRW_WIDTH) $
  }
END



;******************************************************************
; AATSR-specific functions
;******************************************************************



PRO AATSR_GET_HEADERS, UNIT, MPH, SPH, DSD, KEEP_DEFAULTS=KD
;
; VERSION
;     1.1  TJN  15-NOV-2002  Use automatic structure
;                            definitions. Select SPH size
;                            dependent on product type.
;     1.1  TJN  22-OCT-2002  Change DSD read to accomodate
;                            corrected AATSR MPH.NUM_DSD
;                            value in production files.
;     1.0  TJN  05-SEP-2002  Original
;
; DESCRIPTION
;     Wrapper for initialisation routines. Extracts all header
;     information from AATSR product files and returns this
;     through the arguments MPH, SPH and DSD.
;
; MANDATORY ARGUMENT
;     UNIT          Product file unit number
;
; OPTIONAL ARGUMENTS
;     MPH            Main Product Header from product file
;     SPH            AATSR Specific Product Header information,
;                    excluding Data Set Descriptors, from product
;                    file
;     DSD            Array of Data Set Descriptors from product
;                    file
;     KEEP_DEFAULTS  Do not redefine AATSR default values
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Modified by M. BOUVET (mbouvet@esa.int) the 06/01/2006
; The SPH structure was obtained initially with the line:
; 	SPH = ENVISAT_GET_HEADER(Unit, !AATSR.SPH_SIZE.(i), NAME='AATSR_SPH_' + Type)
; 
; This line was changed to:
; 	SPH = ENVISAT_GET_HEADER(Unit, !AATSR.SPH_SIZE.(i))
;
; This change was impolemented because one of the tagnames of the structure
; changed from one file to the next while the structure was a named structure
;
; Code starts here ------------------------------------------------
;
  ENVISAT_DEFINE_CONSTANTS
  AATSR_DEFINE_CONSTANTS, KEEP_DEFAULTS=KD

  MPH = ENVISAT_GET_HEADER(Unit, !ENVISAT.MPH_SIZE, 0, NAME='ENVISAT_MPH')

  Type = STRMID(MPH.PRODUCT, 4, 6)          ; Pick out SPH size
  Tags = TAG_NAMES(!AATSR.SPH_SIZE)         ; corresponding to
  i = (WHERE(Type EQ Tags))[0]              ; file type

  IF (i EQ -1) THEN BEGIN
    i = (WHERE(STRMID(Type, 0, 3) EQ STRMID(Tags, 0, 3)))[0]
    IF (i EQ -1) THEN MESSAGE, 'Unknown file type ''' + Type + '''. Aborting'
    MESSAGE, /INFORM, 'Unknown file type ''' + Type + '''. Trying ''' + Tags[i] + ''''
  ENDIF

  SPH = ENVISAT_GET_HEADER(Unit, !AATSR.SPH_SIZE.(i));, NAME='AATSR_SPH_' + Type)


  IF (Type EQ 'TOA_1P') OR (Type EQ 'NR__2P') THEN BEGIN
    !AATSR.NUM_LOC_TP = N_ELEMENTS(SPH.LAT_LONG_TIE_POINTS)
    !AATSR.NUM_SA_TP = N_ELEMENTS(SPH.VIEW_ANGLE_TIE_POINTS)
  ENDIF

  IF (Type EQ 'TOA_1P') AND (MPH.NUM_DSD NE 38) THEN BEGIN
    MESSAGE, /INFORM, 'Incorrect ''' + Type + ''' MPH.NUM_DSD value. Fixing at 38'
    MPH.NUM_DSD = 38
  ENDIF
;
; Fill DSD array ----------------------------------------------
;
; N.B. Early TOA_1P files had MPH.NUM_DSD=36, the number of
; 'active' DSDs. Later files have MPH.NUM_DSD=38, the total
; number of DSDs, both empty and active. This is implemented
; above.
;
  i = 0
  FOR j = 0, MPH.NUM_DSD-1 DO BEGIN
    Temp = ENVISAT_GET_HEADER(Unit, MPH.DSD_SIZE, NAME='ENVISAT_DSD', N_TAGS=n)
    IF (n EQ 0) THEN CONTINUE
    IF (i EQ 0) THEN DSD = REPLICATE({ENVISAT_DSD}, MPH.NUM_DSD)
    DSD[j] = Temp
    i = i + 1
  ENDFOR
END



FUNCTION AATSR_READ_ADS_LOC, UNIT, DSD, SPH, $
  ALONG, LENGTH, ACROSS, WIDTH, $
  NADIR_CORRECTION=NADIR, FORWARD_CORRECTION=FORWARD, $
  SADIST=SADIST, DEFAULT=DEFAULT
;
; VERSION
;     1.2  TJN  16-OCT-2002  Correct error in ENVISAT_BILINEAR
;                            call when unwinding +/-180 boundaries.
;     1.1  TJN  03-OCT-2002  Add longitude wrap-round trap.
;     1.0  TJN  05-SEP-2002  Original.
;
; DESCRIPTION
;     Fills a WIDTH x LENGTH array with interpolated latitudes and
;     longitudes. All swath positions and sizes (ACROSS, ALONG,
;     WIDTH, LENGTH) are specified in AATSR MDS pixel indices,
;     referred to [0, 0], the first, leftmost pixel in a MDS.
;
;     The output array can underfill or overfill the latitude and
;     longitude records. Any output pixels outside the bounds of
;     these records will contain the DEFAULT value. Note that the
;     limiting across track bounds ACROSS = [-19, 530 or 531] are
;     slightly broader than those for full-resolution gridded MDS
;     products (ACROSS = [0, 511]).
;
;     N.B. As the grid reference data set is small and the read is
;     restricted only to the minimal number of required records,
;     there is no significant advantage to reading the grid records
;     once only and operating on these. Similarly, only two sets of
;     two interpolations are required to generate both nadir and
;     forward corrected fields. Six would be required for
;     pre-computed corrections.
;
;     N.B. By default, interpolated angles are returned for the
;     pixel centres. Set the SADIST switch to return values for
;     the lower left corner of each pixel, as for ATSR-1 and
;     ATSR-2. Also, elevations are returned as zenith angles
;     (angle from vertical), not as elevation angles (angle from
;     horizontal), the AATSR default form.
;
; MANDATORY PARAMETERS
;     UNIT                File unit number.
;     DSD                 Data Set Descriptor DSD #2 for ASD #3
;                         (grid pixel latitude and longitude).
;     SPH                 Structure containing first part of
;                         Specific Product Header.
;
; OPTIONAL PARAMETERS
;     ALONG               Starting along track pixel index
;                         (default: 0).
;     LENGTH              Along track array size (default: 512).
;     ACROSS              Starting across track pixel index
;                         (default: 0).
;     WIDTH               Across track array size (default: 512).
;    /FORWARD_CORRECTION  Apply forward topographic correction to
;                         pixel latitudes and longitudes (default:
;                         none)
;    /NADIR_CORRECTION    Apply nadir topographic correction to
;                         pixel latitudes and longitudes (default:
;                         none).
;    /SADIST              Return latitudes and longitudes at the
;                         lower left pixel corner (default: centre).
;     DEFAULT             Default value for out-of-bounds latitudes
;                         and longitudes (default: -999).
;
; Update defaults ------------------------------------------------
;
  isCentred = 1 - KEYWORD_SET(SADIST)
  IF NOT KEYWORD_SET(Default) THEN Default = !AATSR.DEFAULT.ADS_LOC
  IF NOT KEYWORD_SET(Along)THEN Along = 0L
  IF NOT KEYWORD_SET(Length) THEN Length = !AATSR.DEFAULT.LENGTH
  IF NOT KEYWORD_SET(Across) THEN Across = 0L
  IF NOT KEYWORD_SET(Width) THEN Width = !AATSR.WIDTH
;
; Build output array ---------------------------------------------
;
  Output = REPLICATE( $
    {Latitude:DOUBLE(Default), Longitude:DOUBLE(Default)}, $
  Width, Length)
;
; Skip out if bounds do not overlap ADS records ------------------
;
  IF (Across + isCentred GT SPH.LAT_LONG_TIE_POINTS[!AATSR.NUM_LOC_TP-1]) OR $
    (Along + isCentred GT (DSD.NUM_DSR - 1) * !AATSR.GRANULE) OR $
    (Across + Width LE SPH.LAT_LONG_TIE_POINTS[0]) OR $
    (Along + Length LE 0) $
  THEN RETURN, Output
;
; Calculate array start indices ----------------------------------
;
  i1 = 0 > (SPH.LAT_LONG_TIE_POINTS[0] + !AATSR.WIDTH / 2 - Across)
  j1 = 0 > (-Along)
  l1 = 0 > (Along / !AATSR.GRANULE)
;
; Calculate array stop indices -----------------------------------
;
; N.B. the "...- 2" offset in l2 gives the minimal input
; array size to interpolate integer pixel indices correctly,
; i.e. pixels starting at the upper limit are acceptable
; for "bottom-left" lat/lons.
;
  i2 = (Width - 1) < (SPH.LAT_LONG_TIE_POINTS[!AATSR.NUM_LOC_TP-1] + !AATSR.WIDTH / 2 - Across - isCentred)
  j2 = (Length - 1) < ((DSD.NUM_DSR - 1) * !AATSR.GRANULE - Along - isCentred)
  l2 = (DSD.NUM_DSR - 1) < ((Along + Length - 2 + isCentred) / !AATSR.GRANULE + 1)
;
; Calculate array sizes ------------------------------------------
;
  ni = i2 - i1 + 1
  nj = j2 - j1 + 1
  nl = l2 - l1 + 1
;
; Calculate fractional interpolation indices ----------------------
;
  u = INTERPOL(DINDGEN(!AATSR.NUM_LOC_TP), SPH.LAT_LONG_TIE_POINTS, $
    Across - !AATSR.WIDTH / 2 + i1 + isCentred / 2d0 + LINDGEN(ni))
  v = (Along + j1 + isCentred / 2d0 + LINDGEN(nj)) / !AATSR.GRANULE - l1
;
; Build input array -----------------------------------------------
;
  LOC = REPLICATE({AATSR_ADSR_LOC}, nl)
;
; Move to start point ---------------------------------------------
;
  POINT_LUN, Unit, DSD.DS_OFFSET + l1 * DSD.DSR_SIZE
;
; Fetch valid data ------------------------------------------------
;
  READU, Unit, LOC
;
; Remove +/-180 discontinuities ------------------------------------
;
; Step detects all steps of greater than 180 degrees and their
; signs. Sum is a square matrix filled with '1's on the leading
; diagonal and in the upper/lower triangle, '0's elsewhere. When
; pre-/post-multiplying Step, it propagates the sum of all step
; values along/across track into subsequent pixels. These, suitably
; scaled and added onto the original array, eliminate the step. The
; operation is performed first along and then across track. The
; order is not important.
;
  Sum = LINDGEN(nl-1, nl-1) MOD (nl-1)
  Sum = (TRANSPOSE(Sum) GE TEMPORARY(Sum)) * 360000000L
  Step = (LOC[1:*].TIE_PT_LONG - LOC.TIE_PT_LONG) / 180000000L
  LOC[1:*].TIE_PT_LONG = LOC[1:*].TIE_PT_LONG - (Sum ## Step)

  Sum = LINDGEN(!AATSR.NUM_LOC_TP-1, !AATSR.NUM_LOC_TP-1) MOD (!AATSR.NUM_LOC_TP-1)
  Sum = (TRANSPOSE(Sum) LE TEMPORARY(Sum)) * 360000000L
  Step = (LOC.TIE_PT_LONG[1:*] - LOC.TIE_PT_LONG[0:!AATSR.NUM_LOC_TP-2]) / 180000000L
  LOC.TIE_PT_LONG[1:*] = LOC.TIE_PT_LONG[1:*] - (Step ## Sum)
;
; Apply topographic corrections -----------------------------------
;
  IF KEYWORD_SET(Nadir) THEN BEGIN
    LOC.TIE_PT_LAT = LOC.TIE_PT_LAT + $
      LOC.LAT_CORR_NADV * (LOC.LAT_CORR_NADV NE !AATSR.EXCEPTION.TOPOGRAPHIC)
    LOC.TIE_PT_LONG = LOC.TIE_PT_LONG + $
      LOC.LONG_CORR_NADV * (LOC.LONG_CORR_NADV NE !AATSR.EXCEPTION.TOPOGRAPHIC)
  ENDIF ELSE IF KEYWORD_SET(Forward) THEN BEGIN
    LOC.TIE_PT_LAT = LOC.TIE_PT_LAT + $
      LOC.LAT_CORR_FORV * (LOC.LAT_CORR_FORV NE !AATSR.EXCEPTION.TOPOGRAPHIC)
    LOC.TIE_PT_LONG = LOC.TIE_PT_LONG + $
      LOC.LONG_CORR_FORV * (LOC.LONG_CORR_FORV NE !AATSR.EXCEPTION.TOPOGRAPHIC)
  ENDIF
;
; Interpolate onto output grid ------------------------------------
;
  Output[i1:i2, j1:j2].Latitude = $
    ENVISAT_BILINEAR(1d-6 * LOC.TIE_PT_LAT, u, v)
  Output[i1:i2, j1:j2].Longitude = ( $
    ENVISAT_BILINEAR(1d-6 * (900000000L + LOC.TIE_PT_LONG), u, v) ) MOD 360 - 180     ; u, v are 2-D arrays here

  RETURN, Output
END



FUNCTION AATSR_READ_ADS_SA, UNIT, DSD, SPH, $
  ALONG, LENGTH, ACROSS, WIDTH, SADIST=SADIST, DEFAULT=DEFAULT
;
; VERSION
;     1.2  TJN  16-OCT-2002  Correct error in ENVISAT_BILINEAR
;                            calls when unwinding +/-180 boundaries.
;     1.1  TJN  03-OCT-2002  Change wrap-round code. Default to
;                            lower left corner, not centre.
;     1.0  TJN  11-SEP-2002  Original.
;
; DESCRIPTION
;     Fills a WIDTH x LENGTH array with interpolated solar and
;     satellite azimuth and zenith angles. All swath positions
;     and sizes (ACROSS, ALONG, WIDTH, LENGTH) are specified in
;     AATSR MDS pixel indices, referred to [0, 0], the first,
;     leftmost pixel in a MDS.
;
;     The output array can underfill or overfill the AATSR full-
;     resolution swath. Any output pixels outside the bounds of
;     the swath will contain the DEFAULT value. Note that up to
;     513 across-track pixels are allowed when the SADIST switch
;     is set, although the default is still 512 pixels.
;
;     The view angle ADS is slightly narrower than the full-
;     resolution MDS so the outermost pixels are extrapolated.
;     As the intrinsic IDL INTERPOLATE routine cannot be used,
;     the interpolations are somewhat slower.

;     N.B. By default, interpolated angles are returned for the
;     pixel centres. Set the SADIST switch to return values for
;     the lower left corner of each pixel, as for ATSR-1 and
;     ATSR-2. Also, elevations are returned as zenith angles
;     (angle from vertical), not as elevation angles (angle from
;     horizontal), the AATSR default form.
;
; MANDATORY PARAMETERS
;     UNIT               File unit number.
;     DSD                Data Set Descriptor DSD #2 for ASD #3
;                        (grid pixel latitude and longitude).
;     SPH                Structure containing first part of
;                        Specific Product Header.
;
; OPTIONAL PARAMETERS
;     ALONG              Starting along track pixel index (default: 0).
;     LENGTH             Along track array size (default: 512).
;     ACROSS             Starting across track pixel index (default: 0).
;     WIDTH              Across track array size (default: 512).
;    /SADIST             Return latitudes and longitudes at the
;                        lower left corner (default: centre)
;     DEFAULT            Default value for out-of-bounds latitudes
;                        and longitudes (default: -999).
;
; Update defaults ------------------------------------------------
;
  isCentred = 1 - KEYWORD_SET(SADIST)
  IF NOT KEYWORD_SET(Default) THEN Default = !AATSR.DEFAULT.ADS_SA
  IF NOT KEYWORD_SET(Along)THEN Along = 0L
  IF NOT KEYWORD_SET(Length) THEN Length = !AATSR.DEFAULT.LENGTH
  IF NOT KEYWORD_SET(Across) THEN Across = 0L
  IF NOT KEYWORD_SET(Width) THEN Width = !AATSR.WIDTH
;
; Build output array ---------------------------------------------
;
  Output = REPLICATE( { $
    Solar     : {Zenith : DOUBLE(Default), Azimuth : DOUBLE(Default)}, $
    Satellite : {Zenith : DOUBLE(Default), Azimuth : DOUBLE(Default)}  $
  }, Width, Length)
;
; Skip out if bounds do not overlap MDS records ------------------
;
  IF (Across + isCentred GT !AATSR.WIDTH) OR $
    (Along + isCentred GT (DSD.NUM_DSR - 1) * !AATSR.GRANULE) OR $
    (Across + Width LE 0) OR $
    (Along + Length LE 0) $
  THEN RETURN, Output
;
; Calculate array start indices ----------------------------------
;
  i1 = 0 > (-Across)
  j1 = 0 > (-Along)
  l1 = 0 > (Along / !AATSR.GRANULE)
;
; Calculate array stop indices -----------------------------------
;
; N.B. the "...- 2" offset in l2 gives the minimal input
; array size to interpolate integer pixel indices correctly,
; i.e. pixels starting at the upper limit are acceptable
; for SADIST-style angles.
;
  i2 = (Width - 1) < (!AATSR.WIDTH - Across - isCentred)
  j2 = (Length - 1) < ((DSD.NUM_DSR - 1) * !AATSR.GRANULE - Along - isCentred)
  l2 = (DSD.NUM_DSR - 1) < ((Along + Length - 2 + isCentred) / !AATSR.GRANULE + 1)
;
; Calculate array sizes ------------------------------------------
;
  ni = i2 - i1 + 1
  nj = j2 - j1 + 1
  nl = l2 - l1 + 1
;
; Calculate fractional interpolation indices ----------------------
;
  u = INTERPOL(DINDGEN(!AATSR.NUM_SA_TP), SPH.VIEW_ANGLE_TIE_POINTS, $
    Across - !AATSR.WIDTH / 2 + i1 + isCentred / 2d0 + LINDGEN(ni))
  v = (Along + j1 + isCentred / 2d0 + LINDGEN(nj)) / !AATSR.GRANULE - l1
;
; Build input array -----------------------------------------------
;
  SA = REPLICATE({AATSR_ADSR_SA}, nl)
;
; Move to start point ---------------------------------------------
;
  POINT_LUN, Unit, DSD.DS_OFFSET + l1 * DSD.DSR_SIZE
;
; Fetch valid data ------------------------------------------------
;
  READU, Unit, SA

;
; Remove +/-180 discontinuities ------------------------------------
;
  Sum = LINDGEN(nl-1, nl-1) MOD (nl-1)
  Sum = (TRANSPOSE(Sum) GE TEMPORARY(Sum)) * 360000L
  Step = (SA[1:*].TIE_PT_SOL_AZ - SA.TIE_PT_SOL_AZ) / 180000L
  SA[1:*].TIE_PT_SOL_AZ = SA[1:*].TIE_PT_SOL_AZ - (Sum ## Step)
  Step = (SA[1:*].TIE_PT_SAT_AZ - SA.TIE_PT_SAT_AZ) / 180000L
  SA[1:*].TIE_PT_SAT_AZ = SA[1:*].TIE_PT_SAT_AZ - (Sum ## Step)

  Sum = LINDGEN(!AATSR.NUM_SA_TP-1, !AATSR.NUM_SA_TP-1) MOD (!AATSR.NUM_SA_TP-1)
  Sum = (TRANSPOSE(Sum) LE TEMPORARY(Sum)) * 360000L
  Step = (SA.TIE_PT_SOL_AZ[1:*] - SA.TIE_PT_SOL_AZ[0:!AATSR.NUM_SA_TP-2]) / 180000L
  SA.TIE_PT_SOL_AZ[1:*] = SA.TIE_PT_SOL_AZ[1:*] - (Step ## Sum)
  Step = (SA.TIE_PT_SAT_AZ[1:*] - SA.TIE_PT_SAT_AZ[0:!AATSR.NUM_SA_TP-2]) / 180000L
  SA.TIE_PT_SAT_AZ[1:*] = SA.TIE_PT_SAT_AZ[1:*] - (Step ## Sum)
;
; Interpolate satellite angles onto output grid -------------------
;
  Output[i1:i2, j1:j2].Solar.Azimuth = ( $
    ENVISAT_BILINEAR(1d-3 * (900000L + SA.TIE_PT_SOL_AZ), u, v, /EXTRAPOLATE) ) MOD 360 - 180
  Output[i1:i2, j1:j2].Solar.Zenith = $
    ENVISAT_BILINEAR(1d-3 * ( 90000L - SA.TIE_PT_SOL_EL), u, v, /EXTRAPOLATE)
  Output[i1:i2, j1:j2].Satellite.Azimuth = ( $
    ENVISAT_BILINEAR(1d-3 * (900000L + SA.TIE_PT_SAT_AZ), u, v, /EXTRAPOLATE) ) MOD 360 - 180
  Output[i1:i2, j1:j2].Satellite.Zenith = $
    ENVISAT_BILINEAR(1d-3 * ( 90000L - SA.TIE_PT_SAT_EL), u, v, /EXTRAPOLATE)
;
; Return output array ---------------------------------------------
;
  RETURN, Output
END



FUNCTION AATSR_READ_MDS, UNIT, DSD, ALONG, LENGTH, ACROSS, WIDTH, $
  INT=INT, UINT=DUMMY, DEFAULT=DEFAULT, DSR_TIME=DSR_TIME
;
; VERSION
;     1.1  TJN  25-OCT-2002  Add DSR_TIME option
;     1.0  TJN  02-SEP-2002  Original
;
; DESCRIPTION
;     Fills a WIDTH x LENGTH array with data from the specified
;     Level 1 Measurement Data Set. All swath positions and sizes
;     (ACROSS, ALONG, WIDTH, LENGTH) are specified in AATSR MDS
;     pixel indices, referred to [0, 0], the first, leftmost pixel
;     in the MDS.
;
;     The input array can underfill or overfill the data records.
;     Any output pixels outside the bounds of the the records will
;     contain the DEFAULT value. The limiting across track bounds
;     are ACROSS = [0, 511].
;
; MANDATORY PARAMETERS
;     UNIT      File unit number.
;     DSD       Data Set Descriptor specifying the required
;               Measurement Data Set.
;
; OPTIONAL PARAMETERS
;     ALONG     Starting along track pixel index (default: 0)
;     LENGTH    Along track array size (default: 512)
;     ACROSS    Starting across track pixel index (default: 0)
;     WIDTH     Across track array size (default: 512)
;    /INT       Set output data type to signed integer
;    /UINT      Set output data type to unsigned integer (default)
;     DEFAULT   Default value for unfilled pixels (default: 0)
;     DSR_TIME  Contains Data Set Record (DSR) times as a array of
;               ENVISAT Modified Julian Day (MJD) structures with
;               dimension LENGTH.
;
; Update defaults ------------------------------------------------
;
  Type = 12 - 10 * KEYWORD_SET(Int)
  IF NOT KEYWORD_SET(Default) THEN Default = !AATSR.DEFAULT.MDS
  IF NOT KEYWORD_SET(Along)THEN Along = 0L
  IF NOT KEYWORD_SET(Length) THEN Length = !AATSR.DEFAULT.LENGTH
  IF NOT KEYWORD_SET(Across) THEN Across = 0L
  IF NOT KEYWORD_SET(Width) THEN Width = !AATSR.WIDTH
;
; Build output array ---------------------------------------------
;
  Output = MAKE_ARRAY(Width, Length, TYPE=Type, VALUE=Default)
;
; Skip out if bounds do not overlap MDS records ------------------
;
  IF (Across GE !AATSR.WIDTH) OR (Along GE DSD.NUM_DSR) OR $
    (Across + Width LE 0) OR (Along + Length LE 0) $
  THEN RETURN, Output
;
; Calculate array limits -----------------------------------------
;
  i1 = 0 > (-Across) & i2 = (Width < (!AATSR.WIDTH - Across)) - 1
  j1 = 0 > (-Along)  & j2 = (Length < (DSD.NUM_DSR - Along))  - 1
  k1 = 0 > Across    & k2 = ((Across + Width) < !AATSR.WIDTH) - 1
  l1 = 0 > Along     ; l2 not needed - set by loop limit
;
; Calculate input array size -------------------------------------
;
  nj = j2 - j1 + 1
;
; Move to start point --------------------------------------------
;
  POINT_LUN, Unit, DSD.DS_OFFSET + l1 * DSD.DSR_SIZE
;
; Copy out valid data --------------------------------------------
;
  MDS = REPLICATE({AATSR_MDSR_1P}, nj)
  DSR_Time = REPLICATE({ENVISAT_MJD}, nj)
  READU, Unit, MDS
  Output[i1:i2, j1:j2] = MDS.VALUE[k1:k2]
  DSR_Time[j1:j2] = MDS.DSR_TIME

  RETURN, Output
END



FUNCTION AATSR_READ_MDS_DP, UNIT, DSD, ALONG, LENGTH, ACROSS, WIDTH, $
  CONFIDENCE_WORD=CW, DEFAULT=DEFAULT, DSR_TIME=DSR_TIME, $
  NADIR_VIEW_SST=NSST, DUAL_VIEW_SST=DSST, $
  LST=LST, NDVI=NDVI, CTT=CTT, CTH=CTH, $
  NADIR=NADIR, COMBINED=DUMMY
;
; >>>>>>>>>>>>>> UNDER DEVELOPMENT. NOT YET WORKING!!! <<<<<<<<<<<<<<
;
; VERSION
;     1.0  TJN  02-SEP-2002  Original
;
; DESCRIPTION
;     Fills a WIDTH x LENGTH array with data from the specified
;     Measurement Data Set. All swath positions and sizes (ACROSS,
;     ALONG, WIDTH, LENGTH) are specified in AATSR MDS pixel
;     indices, referred to [0, 0], the first, leftmost pixel in
;     the MDS.
;
;     The input array can underfill or overfill the data records.
;     Any output pixels outside the bounds of the the records will
;     contain the DEFAULT value. The limiting across track bounds
;     are ACROSS = [0, 511].
;
; MANDATORY PARAMETERS
;     UNIT             File unit number.
;     DSD              Data Set Descriptor specifying the required
;                      Measurement Data Set.
;
; OPTIONAL PARAMETERS
;     ALONG            Starting along track pixel index (default: 0)
;     LENGTH           Along track array size (default: 512)
;     ACROSS           Starting across track pixel index (default: 0)
;     WIDTH            Across track array size (default: 512)
;     DEFAULT          Default value for unfilled pixels (default: 0)
;     DSR_TIME         Contains Data Set Record (DSR) times as a
;                      array of ENVISAT Modified Julian Day (MJD)
;     CONFIDENCE_WORD  Return array of confidence words corresponding
;                      to returned product (default: 0)
;                      structures with dimension LENGTH.
;    /NADIR_VIEW_SST   Return nadir view sea surface temperatures
;                      where valid, default value otherwise
;    /DUAL_VIEW_SST    Return nadir view sea surface temperatures
;                      where valid, default value otherwise
;    /LST              Return land surface temperatures where
;                      valid, default value otherwise
;    /NDVI             Return Normalised Difference Vegetation
;                      Index where valid, default value otherwise
;    /CTT              Return cloud top temperature where valid,
;                      default value otherwise
;    /CTH              Return cloud top height where valid, default
;                      value otherwise
;    /NADIR            Return unfiltered nadir field
;    /COMBINED         Return unfilteed combined field
;    /SADIST           Encode SADIST-style negative values for
;                      cosmetic and blanking pulse pixels.
;
; Update defaults ------------------------------------------------
;
  CASE 1 OF
    KEYWORD_SET(NSST)  : BEGIN & Mask =  48 & Test =  0 & isNadir = 1 & END
    KEYWORD_SET(DSST)  : BEGIN & Mask = 304 & Test =  0 & isNadir = 0 & END
    KEYWORD_SET(LST)   : BEGIN & Mask =  48 & Test = 16 & isNadir = 1 & END
    KEYWORD_SET(NDVI)  : BEGIN & Mask =  48 & Test = 16 & isNadir = 0 & END
    KEYWORD_SET(CTT)   : BEGIN & Mask =  32 & Test = 32 & isNadir = 1 & END
    KEYWORD_SET(CTH)   : BEGIN & Mask =  32 & Test = 32 & isNadir = 0 & END
    KEYWORD_SET(Nadir) : BEGIN & Mask =   0 & Test =  0 & isNadir = 1 & END
    ELSE               : BEGIN & Mask =   0 & Test =  0 & isNadir = 0 & END
  END

  Sign = 192 + (Mask EQ 304) * 1536

  IF NOT KEYWORD_SET(Default) THEN Default = !AATSR.DEFAULT.MDS
  IF NOT KEYWORD_SET(Along)THEN Along = 0L
  IF NOT KEYWORD_SET(Length) THEN Length = !AATSR.DEFAULT.LENGTH
  IF NOT KEYWORD_SET(Across) THEN Across = 0L
  IF NOT KEYWORD_SET(Width) THEN Width = !AATSR.WIDTH
;
; Build output array ---------------------------------------------
;
  CW = MAKE_ARRAY(Width, Length, /UINT, VALUE=0)
  Output = MAKE_ARRAY(Width, Length, /INT, VALUE=Default)
;
; Skip out if bounds do not overlap MDS records ------------------
;
  IF (Across GE !AATSR.WIDTH) OR (Along GE DSD.NUM_DSR) OR $
    (Across + Width LE 0) OR (Along + Length LE 0) $
  THEN RETURN, Output
;
; Calculate array limits -----------------------------------------
;
  i1 = 0 > (-Across) & i2 = (Width < (!AATSR.WIDTH - Across)) - 1
  j1 = 0 > (-Along)  & j2 = (Length < (DSD.NUM_DSR - Along))  - 1
  k1 = 0 > Across    & k2 = ((Across + Width) < !AATSR.WIDTH) - 1
  l1 = 0 > Along     ; l2 not needed - set by loop limit
;
; Calculate input array size -------------------------------------
;
  nj = j2 - j1 + 1
;
; Move to start point --------------------------------------------
;
  POINT_LUN, Unit, DSD.DS_OFFSET + l1 * DSD.DSR_SIZE
;
; Copy out valid data --------------------------------------------
;
  MDS = REPLICATE({AATSR_MDSR_DP}, nj)
  DSR_Time = REPLICATE({ENVISAT_MJD}, nj)
  READU, Unit, MDS
  DSR_Time[j1:j2] = MDS.DSR_TIME
  CW[i1:i2, j1:j2] = MDS.CONF_WD_FLAGS[k1:k2]
  OK = (CW[i1:i2, j1:j2] AND Mask) EQ Test
;
; Select preferred view and apply filter -------------------------
;
  IF isNadir THEN $
    Output[i1:i2, j1:j2] = $
    OK * MDS.NAD_FIELD[k1:k2]  + (1 - OK) * Default $
  ELSE $
    Output[i1:i2, j1:j2] = $
    OK * MDS.COMB_FIELD[k1:k2] + (1 - OK) * Default
;
; Add SADIST-style cosmetic and blanking flags -------------------
;
  IF KEYWORD_SET(SADIST) THEN $
    Output[i1:i2, j1:j2] = Output[i1:i2, j1:j2] * $
    (1 - 2 * ((CW[i1:i2, j1:j2] AND Sign) NE 0))

  RETURN, Output
END



FUNCTION AATSR_LOC_TO_INDEX, UNIT, DSD, SPH, LATITUDE, LONGITUDE, $
  DSR_TIME=DSR_TIME, TOLERANCE=T, ITERATIONS=N, SADIST=SADIST
;
; VERSION
;     1.1  TJN  11-NOV-2002  Add SADIST switch for bottom-left
;                            referencing (the default in V1.0)
;     1.0  TJN  01-NOV-2002  Original.
;
; DESCRIPTION
;     Returns the fractional across- and along-track indices to
;     the AATSR MDS array pixel with coordinates LATITUDE and
;     LONGITUDE.
;
;     AATSR_LOC_TO_INDEX() first makes a global search of the
;     grid pixel latitude and longitude ADS for the tie point
;     nearest to the required latitude and longitude, then
;     refines this by Newton-Rapheson iteration to obtain the
;     exact fractional pixel index in "i,j"-space corresponding
;     to the coordinates in "lat,lon"-space. The first coarse
;     search is necessary as, while relation between "i,j"-space
;     and "lat,lon"-space varies little locally, it will change
;     completely through an orbit.
;
;     If the SADIST switch is set, this function returns absolute
;     fractional indices, starting from [0., 0.] at the bottom
;     left corner of the MDS pixel with indices [0, 0]. If the
;     flag is not set, the indices start from [0., 0.] at the
;     centre of pixel [0, 0].
;
;     The integer indices of the pixel containing the given
;     latitude and longitude can be retrieved from the returned
;     fractional indices with the FLOOR() function if SADIST is
;     set, or with the ROUND() function otherwise.
;
;     To generate indices for an image segment read with
;     AATSR_READ_MDS() or similar, subtract the ACROSS and ALONG
;     values supplied to those functions from the returned values
;     *.ACROSS and *.ALONG.
;
; MANDATORY PARAMETERS
;     UNIT        File unit number
;     DSD         Data Set Descriptor DSD #2 for ASD #3 (grid
;                 pixel latitude and longitude)
;     SPH         Structure containing first part of  Specific
;                 Product Header
;     LATITUDE    Scalar latitude to be located (in degrees,
;                 -90.0 -> +90.0, S -> N)
;     LONGITUDE   Scalar latitude to be located, in degrees,
;                 -180.0 -> +179.99..., W -> E)
;
; OPTIONAL PARAMETERS
;     TOLERANCE   Convergence tolerance in index units for
;                 solution iteration (default:1d-3, about 1 metre)
;     ITERATIONS  Returns number of iterations to converge
;    /SADIST      Returned indices are referred to the lower left
;                 pixel corner (default: referred to pixel centre)
;
; Update defaults ------------------------------------------------
;
  IF NOT KEYWORD_SET(t) THEN t = 1d-3
  Offset = 5d-1 * (KEYWORD_SET(SADIST) - 1)
;
; Read in tie point latitudes and longitudes ---------------------
;
  LOC = REPLICATE({AATSR_ADSR_LOC}, DSD.NUM_DSR)
  POINT_LUN, Unit, DSD.DS_OFFSET
  READU, Unit, LOC

;
; Calculate lat/long displacements for each tie point ------------
;
  Lat = 1d6 * Latitude
  Lon = 1d6 * Longitude
  dLat = (LOC.TIE_PT_LAT  - Lat)
  dLon = (LOC.TIE_PT_LONG - Lon)
  dLat = (dLat + 900000000L) MOD 360000000L - 180000000L
  dLon = (dLon + 900000000L) MOD 360000000L - 180000000L
;
; Find nearest tie point -----------------------------------------
;
  x = MIN(dLat^2 + (dLon * COS(!DTOR * Latitude))^2, iMin)
  i = 1 > ((iMin MOD !AATSR.NUM_LOC_TP) < (!AATSR.NUM_LOC_TP - 2))
  j = 1 > ((iMin  /  !AATSR.NUM_LOC_TP) < (DSD.NUM_DSR       - 2))
;
; Calculate approximate Jacobian del(i,j)/del(Lat,Lon) -----------
;
  M = 2 * INVERT( [ $
    [ LOC[j].TIE_PT_LAT[i+1]  - LOC[j].TIE_PT_LAT[i-1],    $
      LOC[j].TIE_PT_LONG[i+1] - LOC[j].TIE_PT_LONG[i-1] ], $
    [ LOC[j+1].TIE_PT_LAT[i]  - LOC[j-1].TIE_PT_LAT[i],    $
      LOC[j+1].TIE_PT_LONG[i] - LOC[j-1].TIE_PT_LONG[i] ]  $
  ] )
;
; Refine tie point by Newton-Rapheson method ---------------------
;
  n = 0
  ij = [i, j]
  REPEAT BEGIN
    dLat = ENVISAT_BILINEAR(LOC.TIE_PT_LAT,  ij[0], ij[1]) - Lat
    dLon = ENVISAT_BILINEAR(LOC.TIE_PT_LONG, ij[0], ij[1]) - Lon
    dij = M # [dLat, dLon]
    ij = ij - dij
    n = n + 1
  ENDREP UNTIL (TOTAL(dij^2) LE t^2) OR (n EQ 20)
;
; Calculate time from along track pixel number ------------------
;
; Assumes time is given for the pixel centre, but coordinates are
; referred to the lower left pixel edge
;
  j = FLOOR(ij[1])
  j = (0 > j) < (DSD.NUM_DSR - 2)
  dj = ij[1] - j - (5d-1 + Offset) / !AATSR.GRANULE
  j = j + [0, 1]
  D = (LOC[j].DSR_TIME.DAY * 86400LL + LOC[j].DSR_TIME.SECOND) * 1000000LL + LOC[j].DSR_TIME.MICROSECOND
  D = D[0] + ROUND(dj * (D[1] - D[0]))
  DSR_TIME = {ENVISAT_MJD}
  DSR_TIME.MICROSECOND = D MOD 1000000LL
  DSR_TIME.SECOND = (D / 1000000LL) MOD 86400LL
  DSR_TIME.DAY = D / 86400000000LL
;
; Rescale to pixel indices ---------------------------------------
;
  Across = Offset + !AATSR.WIDTH / 2 + $
    INTERPOL(SPH.LAT_LONG_TIE_POINTS, DINDGEN(!AATSR.NUM_LOC_TP), ij[0])
  Along = Offset + ij[1] * !AATSR.GRANULE

  RETURN, {ACROSS:Across, ALONG:Along}
END



FUNCTION AATSR_READ_TRACK, UNIT, DSD, JDAY=JDAY, COUNT=N
;
; VERSION
;     1.0  TJN  06-SEP-2002  Original
;
; DESCRIPTION
;     Returns an array of structures containing all sub-satellite
;     times, latitudes, longitudes and along track distances within
;     the referenced annotation data set.
;
; MANDATORY PARAMETERS
;     UNIT     File unit number.
;     DSD      Data Set Descriptor DSD #2 for ADS #3 (grid pixel
;              latitude and longitude).
;
; OPTIONAL PARAMETERS
;    /JDAY     Return time as year and JDay (default: MJD).
;     COUNT    Number of entries in output array.
;
; Build input array -----------------------------------------------
;
  n = DSD.NUM_DSR
  LL = REPLICATE({AATSR_ADSR_LOC}, n)
;
; Move to start point ---------------------------------------------
;
  POINT_LUN, Unit, DSD.DS_OFFSET
;
; Fetch data ------------------------------------------------------
;
  READU, Unit, LL

;
; Build and fill output array -------------------------------------
;
  IF KEYWORD_SET(JDay) THEN BEGIN
    Output = REPLICATE({Year:0, JDay:0d0, Latitude:0d0, Longitude:0d0, ATD:0d0}, n)
    ENVISAT_MJD_TO_JDAY, REFORM(LL.DSR_TIME), Y, J
    Output.Year = Y & Output.JDay = J
  ENDIF ELSE BEGIN
    Output = REPLICATE({MJD:{ENVISAT_MJD}, Latitude:0d0, Longitude:0d0, ATD:0d0}, n)
    Output.MJD = LL.DSR_TIME
  ENDELSE

  Output.Latitude = 1d-6 * LL.TIE_PT_LAT[!AATSR.NUM_LOC_TP / 2]
  Output.Longitude = 1d-6 * LL.TIE_PT_LONG[!AATSR.NUM_LOC_TP / 2]
  Output.ATD = 1d-3 * LL.IMAG_SCAN_Y

  RETURN, Output
END
