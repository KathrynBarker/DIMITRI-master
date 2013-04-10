; LIBRARY ENVISAT.PRO (c) RAL/CCLRC 2002
;
; VERSION
;     1.3  TJN  09-JAN-2003  Add ENVISAT_READ_DS generic data set
;                            reading routine.
;     1.2  TJN  18-NOV-2002  Change ENVISAT_DEFINE_MJD function
;                            name to take advantage of automatic
;                            IDL structure definitions.
;     1.1  TJN  25-OCT-2002  Add ENVISAT_MJD_TO_TIME and associated
;                            routines to generate date and time
;                            strings from MJDs.
;     1.0  TJN  16-SEP-2002  Original.
;
; DESCRIPTION
;      ENVISAT generic structure prototypes and routines to ingest
;      instrument data.
;
; Code starts here ------------------------------------------------
;



;******************************************************************
; ENVISAT constants
;******************************************************************



PRO ENVISAT_DEFINE_CONSTANTS
;
; VERSION
;     1.0  TJN  05-SEP-2002  Original
;
; DESCRIPTION
;     Program-wide definitions for constants not contained
;     in the product file.
;
; Code starts here ------------------------------------------------
;
  DEFSYSV, '!ENVISAT', {ENVISAT_CONSTANTS, $
    MPH_SIZE      : 1247,     $
    SPH_SIZE      :  836      $   ; L0 SPH size (all instruments)
  }
END



;******************************************************************
; ENVISAT prototype structures
;******************************************************************



PRO ENVISAT_MJD__DEFINE
;
; VERSION
;     1.1  TJN  15-NOV-2002  Change function name from
;                            ENVISAT_DEFINE_MJD to take advantage
;                            of automatic structure definitions.
;     1.0  TJN  05-SEP-2002  Original
;
; DESCRIPTION
;     Generates a structure prototype for the ENVISAT Modified
;     Julian Day time representation.
;
; Code starts here ------------------------------------------------
;
  Temp = {ENVISAT_MJD, $
    DAY         : 0L,  $
    SECOND      : 0UL, $
    MICROSECOND : 0UL  $
  }
END



;******************************************************************
; ENVISAT generic functions
;******************************************************************



FUNCTION ENVISAT_BILINEAR, P, IX, JY, EXTRAPOLATE=EX
;
; VERSION
;     1.0  TJN  16-SEP-2002  Original
;
; DESCRIPTION
;     Drop-in replacement for the IDL routine BILINEAR, with the
;     exception that ENVISAT_BILINEAR can extrapolate beyond the
;     limits of the input array P when EXTRAPOLATE is set, whereas
;     BILINEAR limits at the appropriate extreme value in P.
;     Extrapolation is needed for the edges of AATSR solar and
;     satellite view angles.
;
;     Array initialisation - matrix multiplication vs. row-by-row
;     copies in BILINEAR - is MUCH faster in this version.
;
; Get array sizes -------------------------------------------------
;
  sp = SIZE(p)
  si = SIZE(ix)
  sj = SIZE(jy)
;
; Build 2-D indices if needed ------------------------------------
;
  IF (si[0] EQ 1) THEN ix = ix # REPLICATE(1, sj[sj[0]])
  IF (sj[0] EQ 1) THEN jy = REPLICATE(1, si[1]) # jy
;
; Skip out if extrapolation not required -------------------------
;
  IF NOT KEYWORD_SET(Ex) THEN RETURN, INTERPOLATE(p, ix, jy)
;
; Make 'x' indices and offsets -----------------------------------
;
  i0 = (0 > FLOOR(ix)) < (sp[1] - 2)
  i1 = i0 + 1
  di = ix - i0
;
; Make 'y' indices and offsets -----------------------------------
;
  j0 = (0 > FLOOR(jy)) < (sp[2] - 2)
  j1 = j0 + 1
  dj = jy - j0
;
; Interpolate P array to IX and JY virtual indices ---------------
;
; N.B. 4 * , 8 +/- here, v.s. 8 *, 7 +/- in old BILINEAR method
;
  RETURN, P[i0, j0] + $
    di * (P[i1, j0] - P[i0, j0]) + $
    dj * (P[i0, j1] - P[i0, j0]) + $
    di * dj * (P[i0, j0] - P[i1, j0] - P[i0, j1] + P[i1, j1])
END



FUNCTION ENVISAT_GET_VALUE, TOKEN
;
; VERSION
;     1.0  TJN  02-SEP-2002  Original
;
; DESCRIPTION
;     Interprets tokens parsed by ENVISAT_GET_HEADER as values.
;
; MANDATORY PARAMETER
;     TOKEN    Token string representing value
;
; Fetch byte stream ------------------------------------------
;
  IF (STRMID(Token, 0, 1) EQ '"') THEN RETURN, STRMID(Token, 1) ; Character strings
  IF (STRPOS(Token, '.') GE 0) THEN RETURN, DOUBLE(Token)       ; Floating point
  IF (STREGEX(Token, '[A-Za-z]') GE 0) THEN RETURN, Token       ; Single letters
  i = STRSPLIT(Token, '+-', LENGTH=j) & n = N_ELEMENTS(i)       ; Identify multiple elements
  IF (n GT 1) THEN RETURN, LONG64(STRMID(Token, i-1, j+1))      ; Integer array
  RETURN, LONG64(Token)                                         ; Integer
END



FUNCTION ENVISAT_GET_HEADER, UNIT, LENGTH, OFFSET, NAME=NAME, N_TAGS=NTAGS
;
; VERSION
;     1.0  TJN  02-SEP-2002  Original
;
; DESCRIPTION
;     Breaks up byte stream into tokens. Strips out all units
;     <...>, equality signs, and trailing white space and
;     close quotes in string expressions, leaving the opening
;     quote as a string marker. Loads tokens into output
;     structure.
;
; MANDATORY PARAMETERS
;     UNIT     File unit number
;     LENGTH   Size of header in bytes
;
; OPTIONAL PARAMETERS
;     OFFSET   Offset into file of header start in bytes
;              (default: current file position)
;     NAME     Output structure name (default: anonymous)
; Fetch byte stream ------------------------------------------
;
  BS = BYTARR(Length)
  IF KEYWORD_SET(Offset) THEN POINT_LUN, Unit, Offset
  READU, Unit, BS
;
; Split into tokens ------------------------------------------
;
  Token = STRSPLIT(STRING(BS), '<[ -z]+>| *= *| *"?' + STRING(10B), /REGEX, /EXTRACT)

  n = N_ELEMENTS(Token)
  nTags = n / 2 & IF (nTags EQ 0) THEN RETURN, -1
;
; Load tokens into output structure --------------------------
;
  x = CREATE_STRUCT(Token[0], ENVISAT_GET_VALUE(Token[1]))
  FOR i = 2, n-2, 2 DO BEGIN
  x = CREATE_STRUCT(x, token[i], ENVISAT_GET_VALUE(Token[i+1])) 
  ENDFOR	
  RETURN, CREATE_STRUCT(x, NAME=Name)

END



FUNCTION ENVISAT_INDEX_DSD, DSD, N_TAGS=J, ADS=A, GADS=G, MDS=M, REFERENCE=R, NAME=NAME
;
; VERSION
;     1.2  TJN  11-NOV-2002  Add GADS option
;     1.1  TJN  22-OCT-2002  Functionality extended. Original
;                            equivalent to /ADS and /MDS options.
;     1.0  TJN  11-OCT-2002  Original
;
; DESCRIPTION
;     Returns a structure with tag names constructed from
;     sanitised versions of DSD[*].DS_NAME. Tags for the reference
;     ('R') files contain the file name. Those for data sets
;     contain the index to the corresponding DSD, e.g., for AATSR:
;
;       Index    = ENVISAT_INDEX_DSD(DSD)
;       Quality  = AATSR_READ_ADS_SQ(Unit, DSD[Index.SUMMARY_QUALITY_ADS])
;       Filename = Index.INSTRUMENT_DATA_FILE
;
;     By default, ENVISAT_INDEX_DSD returns values for all data set
;     types.
;
; MANDATORY PARAMETERS
;     DSD        Array of Data Set Descriptors.
;
; OPTIONAL PARAMETERS
;    /ADS        Return indices to Annotation Data Set DSDs.
;    /GADS       Return indices to Global Annotation Data Set DSDs.
;    /MDS        Return indices to Measurement Data Set DSDs.
;    /REFERENCE  Return reference filenames.
;     NAME       Output structure name (default: anonymous)
;
; Choose options ------------------------------------------------------
;
  ADS  = KEYWORD_SET(A)
  GADS = KEYWORD_SET(G)
  MDS  = KEYWORD_SET(M)
  Ref  = KEYWORD_SET(R)
  None = NOT (ADS OR GADS OR MDS OR Ref)
  ADS  = None OR ADS
  GADS = None OR GADS
  MDS  = None OR MDS
  Ref  = None OR Ref
;
; Fill structure -----------------------------------------------------
;
  j = 0L
  FOR i = 0L, N_ELEMENTS(DSD)-1 DO BEGIN
    IF      ADS  AND (DSD[i].DS_TYPE EQ 'A') THEN Value = i $
    ELSE IF GADS AND (DSD[i].DS_TYPE EQ 'G') THEN Value = i $
    ELSE IF MDS  AND (DSD[i].DS_TYPE EQ 'M') THEN Value = i $
    ELSE IF Ref  AND (DSD[i].DS_TYPE EQ 'R') THEN Value = DSD[i].FILENAME $
    ELSE CONTINUE
    Tag = STRJOIN(STRSPLIT(DSD[i].DS_NAME, '    ()[]{}/\.', /EXTRACT), '_')
    IF (STREGEX(Tag, '[0-9]') EQ 0) THEN Tag = '_' + Tag
    IF (j EQ 0) THEN Index = CREATE_STRUCT(Tag, Value) $
    ELSE Index = CREATE_STRUCT(Index, Tag, Value)
    j = j + 1
  ENDFOR

  RETURN, CREATE_STRUCT(Index, NAME=Name)
END



FUNCTION ENVISAT_LEAPYEAR, YEAR
;
; VERSION
;     1.0  TJN  06-SEP-2002  Original
;
; DESCRIPTION
;     Returns '1' for leap years, '0' otherwise.
;
; MANDATORY PARAMETERS
;     YEAR     Input scalar or array of years
;
; Code starts here ---------------------------------------------------
;
  RETURN, (Year MOD 4 EQ 0) AND NOT $
    ( (Year MOD 100 EQ 0) AND NOT (Year MOD 400 EQ 0) )
END



PRO ENVISAT_JDAY_TO_DAY, YEAR, JDAY, MONTH, DAY
;
; VERSION
;     1.1  TJN  20-NOV-2002  Ensure that JDAY scalars and any-
;                            dimensional arrays accepted and, if
;                            a scalar YEAR is given, it is used
;                            for all elements of an array JDAY.
;                            return consistent scalar or array
;                            MONTH and DAY
;     1.0  TJN  25-OCT-2002  Original
;
; DESCRIPTION
;     Calculates MONTH and DAY from JDAY. The algorithm sums all
;     permutations of (JDAY GE Day[]) over the elements of Day[],
;     where Day[] is an array containing the first Julian day
;     of the month.
;
; MANDATORY PARAMETERS
;     YEAR    Scalar or array containing year
;     JDAY    Scalar or array containing Julian day, defined as
;             the integer or fractional day of the year, starting
;             at 1.0 at the beginning of the 1st January
;
; OPTIONAL PARAMETERS
;     MONTH   Output scalar or array containing month number
;     DAY     Output scalar or array containing day number
;
; Start with first days of month ----------------------------------
;
  Days = [ $
    [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335], $
    [1, 32, 61, 92, 122, 153, 183, 214, 245, 275, 306, 336]  $
  ]
;
; Force all input arrays to be 1D ---------------------------------
;
  s = SIZE(JDay)
  n = s[s[0] + 2]
  J = REFORM([JDay], n)
  IF (N_ELEMENTS(Year) GT 1) THEN LY = ENVISAT_LEAPYEAR(Year) $
  ELSE LY = REPLICATE(ENVISAT_LEAPYEAR(Year[0]), n)
;
; The interesting stuff -------------------------------------------
;
  One = 1  + INTARR(12)
  D = TRANSPOSE(Days[*, LY])
  Month = FIX(((J # One) GE D) # One)
  Day = 1 + J - Days[Month - 1, LY]
;
; Unwind output arrays to conform to the input array dimensions ---
;
  IF (s[0] EQ 0) THEN BEGIN
    Month = Month[0]
    Day = Day[0]
  ENDIF ELSE BEGIN
    Month = REFORM(Month, s[1:s[0]], /OVERWRITE)
    Day = REFORM(Day, s[1:s[0]], /OVERWRITE)
  ENDELSE
END



PRO ENVISAT_MJD_TO_JDAY, MJD, YEAR, JDAY, INTEGER=INTEGER
;
; VERSION
;     1.2  TJN  20-NOV-2002  Ensure that any-dimensional MJD array
;                            accepted and that returned YEAR and
;                            JDAY array dimensions are consistent
;                            with MJD array
;     1.1  TJN  25-OCT-2002  Revamped to cope properly with single
;                            values. INTEGER option added
;     1.0  TJN  06-SEP-2002  Original
;
; DESCRIPTION
;     Calculates YEAR and JDAY from ENVISAT MJD. The algorithm sums
;     all permutations of (MJD[].DAY GE Day[]) over the elements of
;     Day[], where Day[] is an array containing the first day of the
;     year, starting at 2000.
;
; MANDATORY PARAMETERS
;     MJD     Input scalar or array of ENVISAT_MJD structures
;             containing ENVISAT Modified Julian Day values
;
; OPTIONAL PARAMETERS
;     YEAR     Output array containing year
;     JDAY     Output array containing Julian day, defined as the
;              fractional day of the year, starting at 1.0 at the
;              beginning of the 1st January
;    /INTEGER  Return integer part of Julian day only
;
; Start with first day of year -------------------------------------
;
  Days = [0, 366, 731, 1096, 1461, 1827, 2192, 2557, 2922, 3288]
;
; Force input array to be 1D ---------------------------------------
;
  s = SIZE(MJD)
  n = s[s[0] + 2]
  M = REFORM(MJD, n)
;
; The interesting stuff -------------------------------------------
;
  One = 1 + INTARR(10)              ; TRANSPOSE + INTARR force D to
  D = TRANSPOSE(Days[*, INTARR(n)]) ; a 2D array for all MJD sizes
  Year = FIX(1999 + ((M.DAY # One) GE D) # One)
  JDay = 1 + M.DAY - Days[Year - 2000]
  IF NOT KEYWORD_SET(Integer) THEN $
    JDay = JDay + (1000000ULL * M.SECOND + M.MICROSECOND) / 8.64d10
;
; Unwind output arrays to conform to the input array dimensions ---
;
  Year = REFORM(Year, s[1:s[0]], /OVERWRITE)
  JDay = REFORM(JDay, s[1:s[0]], /OVERWRITE)
END



PRO ENVISAT_MJD_TO_TIME, MJD, DATE, TIME, DECIMAL_PLACES=DP
;
; VERSION
;     1.1  TJN  15-NOV-2002  Tinker with formatting statements.
;     1.0  TJN  25-OCT-2002  Original
;
; DESCRIPTION
;     Given an ENVISAT Modified Julian Day (MJD) scalar or 1D array,
;     returns string scalars or arrays containing date (DD-MMM-YYYY)
;     and time (HH:MM:SS[.SSSSSS]), both rounded to DECIMAL_PLACES
;     seconds.
;
; MANDATORY PARAMETERS
;     MJD     Input scalar or array of ENVISAT_MJD structures
;             containing ENVISAT Modified Julian Day values
;
; OPTIONAL PARAMETERS
;     DATE            String scalar or array containing MJD date
;     TIME            String scalar or array containing MJD time
;     DECIMAL_PLACES  Number of seconds decimal places (0-6, default:3)
;
; Build time string --------------------------------------------------
;
  IF (N_ELEMENTS(DP) GT 0) THEN Place = (0 > ROUND(DP)) < 6 ELSE Place = 3
  Div = 10L ^ Place & Div6 = 1000000L / Div

  x = (1000000LL * MJD.SECOND + MJD.MICROSECOND + Div6 / 2) / Div6
  Thou   =  x MOD Div  & x = x / Div
  Second =  x MOD 60   & x = x / 60
  Minute =  x MOD 60   & x = x / 60
  Hour   =  x MOD 24

  Time = STRING(Hour,  FORMAT='(I2.2)') + $
    STRING(Minute, FORMAT='(":",I2.2)') + $
    STRING(Second, FORMAT='(":",I2.2)')

  IF (Place GT 0) THEN BEGIN
    P = STRTRIM(Place, 2)
    Format = '(".",I' + P + '.' + P + ')'
    Time = Time + STRING(Thou, FORMAT=Format)
  ENDIF
;
; Build time string --------------------------------------------------
;
  Name = ['BAD', $
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', $
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'  $
  ]

  Wrap = MJD & Wrap.Day = Wrap.Day + (x EQ 24)
  ENVISAT_MJD_TO_JDAY, Wrap, Year, JDay, /INTEGER
  ENVISAT_JDAY_TO_DAY, Year, JDay, Month, Day

  Date = STRING(Day, FORMAT='(I2.2)') + $
    STRING(Name[Month], FORMAT='("-",A3)') + $
    STRING(Year, FORMAT='("-",I4.4)')
END



FUNCTION ENVISAT_READ_DS, UNIT, DSD, RECORD, OFFSET=OFFSET, SIZE=SIZE
;
; VERSION
;     1.0  TJN  09-JAN-2003  Original
;
; DESCRIPTION
;     Reads in any ENVISAT data set or, optionally, a subsection
;     of the data set. If any supplied values of OFFSET and SIZE
;     describe a segment that extends beyond the dataset, the
;     returned array is truncated at the data set boundaries. If
;     the required segment does not overlap the data set then the
;     error value -1 is returned.
;
; MANDATORY PARAMETERS
;     UNIT     File unit number
;     DSD      Data Set Descriptor specifying the required
;              Measurement Data Set
;     RECORD   Prototype data set record structure
;
; OPTIONAL PARAMETERS
;     OFFSET   Starting record number (default: 0)
;     SIZE     Number of records returned (default: To end of DS)
;
; Code starts here with input conditions -------------------------
;
  IF NOT KEYWORD_SET(Offset) THEN Offset = 0L
  IF NOT KEYWORD_SET(Size) THEN Size = DSD.NUM_DSR - Offset
;
; Skip out if no valid data --------------------------------------
;
  IF (Offset GE DSD.NUM_DSR) OR (Offset + Size LE 0) THEN RETURN, -1
;
; Calculate (truncated) offset and size --------------------------
;
  i = Offset > 0
  n = ((Size + Offset) < DSD.NUM_DSR) - i
;
; Move to start point --------------------------------------------
;
  POINT_LUN, Unit, DSD.DS_OFFSET + i * DSD.DSR_SIZE
;
; Copy out coefficients ------------------------------------------
;
  DS = REPLICATE(Record, n)
  READU, Unit, DS
  RETURN, DS
END
