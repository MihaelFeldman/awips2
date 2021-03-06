C MODULE GPXSIX
C
      SUBROUTINE GPXSIX(MAXCRD, JCARD, NFLD, IPCODE, NP, ITYPE, INTEGR,
     * REAL, ISTRT, LENGTH, LASK, NREP, LCHAR, CHAR, ISTATF, IERROR,
     * N6P)
C
C.....THIS SUBROUTINE PROCESSES SIX HOUR PRECIPITATION. IT IS DESIGNED
C.....TO HANDLE SIX HOUR PRECIPITATION DATA EITHER AS INDIVIDUAL AMOUNTS
C.....AS REPEAT FACTORS OR AS NULL FIELDS.
C
C.....ARGUMENTS ARE:
C
C.....MAXCRD - THE MAXIMUM NUMBER OF CARD IMAGES AVAILABLE TO STORE
C.....         RUNTIME MOD HEADER AND DATA.
C.....JCARD  - THE ACTUAL NUMBER OF CARD IMAGES USED.
C.....NFLD   - FIELD NO. (FROM UFIEL2).
C.....IPCODE - PROCESS CODE
C.....          = 1   PROCESS THIS SUBROUTINE
C.....          = 0   DO NOT PROCESS THIS SUBROUTINE
C.....NP     - SIX HR GROUP COUNTER -- POINTER TO N6P LOCATION.
C.....ITYPE  - FIELD TYPE (FROM UFIEL2).
C.....INTEGR - INTEGER VALUE OF FIELD (FROM UFIEL2).
C.....REAL   - REAL NO. VALUE OF FIELD (FROM UFIEL2).
C.....ISTRT  - STARTING LOCATION OF FIELD (FROM UFIEL2).
C.....LENGTH - LENGTH OF FIELD (FROM UFIEL2).
C.....LASK   - LOCATION IN FIELD OF ASTERISK (FROM UFIEL2).
C.....NREP   - REPEAT FACTOR (FROM UFIEL2).
C.....LCHAR  - NO. OF I*4 WORDS AVAILABLE IN CHAR.
C.....CHAR   - CHARACTER STRING ARRAY (FILLED BY UFIEL2).
C.....ISTATF - STATUS CODE (FROM UFIEL2).
C.....IERROR - ERROR CODE FOR THIS SUBROUTINE.
C.....N6P    - DISTRIBUTION PERCENTAGE ARRAY.
C
C.....ORIGINALLY WRITTEN BY
C
C.....JERRY M. NUNN       WGRFC FT. WORTH, TEXAS       SEPTEMBER 1986
C
      INTEGER*2 N6P(1)
      INCLUDE 'gcommon/explicit'
C
      DIMENSION CHAR(1), JCARD(20,1), SNAME(2)
C
      INCLUDE 'common/where'
      INCLUDE 'common/ionum'
      INCLUDE 'common/pudbug'
      INCLUDE 'common/errdat'
      INCLUDE 'gcommon/gsize'
      INCLUDE 'ufreex'
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/fcst_maro/RCS/gpxsix.f,v $
     . $',                                                             '
     .$Id: gpxsix.f,v 1.2 1998/07/02 20:34:32 page Exp $
     . $' /
C    ===================================================================
C
C
      DATA GPXP, SNAME /4hGPXP, 4hGPXS, 4hIX  /
C
  900 FORMAT(1H0, '***** WARNING *****   SIX HOURLY PRECIPITATION VALUE
     *OF ', F8.2, ' EXCEEDS INPUT MAXIMUM VALUE OF ', F8.2, /, 7X, 'CHEC
     *K FOR POSSIBLE TYPO ERROR.')
  901 FORMAT(1H0, '***** WARNING *****   REPEAT FACTOR IS TOO LARGE FOR
     *NUMBER OF SIX HOUR PERIODS LEFT TO COMPUTE.', /, 7X, 'YOU HAVE ENC
     *ODED A REPEAT FACTOR OF ', I4, ' BUT YOU HAVE REMAINING ONLY ',
     * I4, ' PERIODS TO COMPUTE.', /, 7X, 'REPEAT FACTOR VALUE CHANGED T
     *O ', I4, '.')
  902 FORMAT(1H0, '*** GPXSIX ENTERED -- PROCESS CODE IS ', I2, ' ***')
  903 FORMAT(1H0, '*** EXIT GPXSIX -- ERROR RETURN CODE IS ',
     * I2, ' ***')
  904 FORMAT(1H0, '*** A CHARACTER STRING HAS BEEN PARSED ***', /, 5X,
     * 'FIELD NO. ', I4, ' OF CARD NO. ', I4, ' BEGINS IN COL. ', I4,
     * ' AND ENDS IN COL. ', I4, '. THE FIELD IS ', I4, ' CHARACTERS IN
     * LENGTH.', /, 5X, 'THE FIELD CONTENTS IS:  ', 10A4, /, 5X, 'THE L
     *OCATION OF THE ASTERISK IS IN COL. ', I4, '. THE REPEAT FACTOR IS
     * ', I4)
C
      INCLUDE 'gcommon/setwhere'
      IERROR = 0
      IF(IPTRCE .GE. 3) WRITE(IOPDBG,902) IPCODE
      IBUG = IPBUG(GPXP)
C
C.....CHECK PROCESS CODE.
C
      IF(IPCODE .EQ. 0) GOTO 999
C
C.....TEST RETURN CODE
C
      IF(ISTATF .GT. 1) GOTO 400
C
C.....IF THIS IS FIRST OF SIX HOUR FIELDS...INITIALIZE VARIABLES.
C
      IF(NFLD .GT. 3) GOTO 120
C
C.....INITIALIZE.
C
      NP = 0
C
      DO 100 KP = 1, 4
      N6P(KP) = 0
  100 CONTINUE
C
C.....UPDATE SIX HOUR COUNTER AND TEST VALUE. WE ONLY NEED 4 OF THE SIX
C.....HOUR FIELDS.
C
  120 NP = NP + 1
      IF(NP .GT. 4) GOTO 420
C
C.....CHECK THE STRING TYPE.
C
      IF(ITYPE .EQ. 0) GOTO 160
      IF(ITYPE .EQ. 1) GOTO 140
      IF(ITYPE .EQ. 2) GOTO 400
C
C.....CHECK IF THERE IS A NULL FIELD. IF SO, WE WILL TREAT ITS
C.....VALUE AS ZERO.
C
      IF(ITYPE .EQ. -1) GOTO 130
      GOTO 400
C
C.....IF THE LENGTH IS ZERO...WE HAVE A NULL FIELD.
C
  130 IF(LENGTH .EQ. 0) GOTO 180
      GOTO 400
C
C.....FIRST...IF THE VALUE IS REAL, CONVERT IT TO AN INTEGER.
C
  140 INTEGR = REAL*100. + 0.5
C
C.....TEST THE VALUE OF THE SIX HOURLY FIELD AGAINST THE PERMISSIBLE
C.....UPPER AND LOWER LIMITS.
C
  160 IF(INTEGR .LT. 0) GOTO 410
      IF(INTEGR .GT. MAXPC6) GOTO 170
C
C.....CHECK FOR THE PRESENCE OF A REPEAT FACTOR.
C
      IF(NREP .LE. 0) GOTO 180
      IF(LASK .GT. 0) GOTO 200
      GOTO 180
C
C.....WHEN THE VALUE IS OUT OF THE PERMISSIBLE RANGE, WRITE A MESSAGE.
C
  170 PX6 = INTEGR
      PX6 = PX6/100. + 0.005
      PX6MAX = MAXPC6
      PX6MAX = PX6MAX/100. + 0.005
      WRITE(IOERR,900) PX6, PX6MAX
      IERROR = 8
C
C.....STORE THE SIX HOUR PRECIPITATION AMOUNT.
C
  180 N6P(NP) = INTEGR
      GOTO 999
C
C
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
C
C.....THE GROUP OF STATEMENTS BEGINNING BELOW IS EXECUTED WHEN AN
C.....ASTERISK IS PRESENT IN THE FIELD, AND THE REPEAT FACTOR IS A
C.....POSITIVE NUMBER. THEN THE STRING CONTAINS A REPEAT FACTOR, WHICH
C.....IS VALID. OTHERWISE, THE STRING IS INVALID.
C
C.....THERE IS AN ASTERISK. NOW CHECK IF THE REPEAT FACTOR IS POSITIVE
C.....AND LESS THAN OR EQUAL TO 4. IF SO, IT IS VALID.
C
C.....JP IS THE NUMBER OF TIME PERIODS LEFT TO PROCESS.
C
  200 JP = 4 - NP + 1
      IF(NREP .LE. JP) GOTO 210
C
C.....WHEN THE REPEAT FACTOR IS TOO LARGE FOR THE REMAINING AMOUNT OF
C.....SIX HOUR DISTRIBUTIONS LEFT TO COMPUTE, ISSUE A WARNING MESSAGE.
C
      LP = JP
      WRITE(IOERR,901) NREP, LP, LP
      IERROR = 9
      NREP = LP
C
  210 KP = NREP
C
C.....STORE THE INTEGER NUMBER THE NUMBER OF TIMES DICTATED BY THE
C.....REPEAT FACTOR.
C
  230 DO 240 LP = 1, KP
      IF(NP .GT. 4) GOTO 420
      N6P(NP) = INTEGR
      NP = NP + 1
  240 CONTINUE
C
C.....THE TIME PERIOD COUNTER IS INCREMENTED ONE TOO MUCH WHEN
C.....THE LOOP IS EXITED.
C
      NP = NP - 1
C
C.....PROCESSING COMPLETE.
C
      GOTO 999
C
C.....ERROR EXITS.
C
  400 IERROR = 7
      GOTO 999
C
  410 IERROR = 6
      GOTO 999
C
  420 IERROR = 9
      GOTO 999
C
  999 IF(IPTRCE .GE. 3) WRITE(IOPDBG,903) IERROR
      RETURN
      END
