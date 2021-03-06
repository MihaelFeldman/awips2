C MEMBER ECOBCK
C  (from old member EECOBCK)
C
      SUBROUTINE ECOBCK(JDFC,JHFC,IER)
C
C   THIS SUBROUTINE SEARCHES CO DATES IN FCSEGC FOR A GIVEN
C   JULIAN DAY AND HOUR.
C
C   THIS SUBROUTINE WAS ORIGINALLY WRITTEN BY GERALD N. DAY .
C
      INCLUDE 'common/fcsegc'
      INCLUDE 'common/fctime'
      INCLUDE 'common/fccgd'
      INCLUDE 'common/ionum'
      INCLUDE 'common/where'
      INCLUDE 'common/fdbug'
      INCLUDE 'common/etime'
C
      DIMENSION SBNAME(2),OLDOPN(2),IXDAY(20),IXTIM(20)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/ofs/src/shared_esp/RCS/ecobck.f,v $
     . $',                                                             '
     .$Id: ecobck.f,v 1.1 1995/09/17 19:18:27 dws Exp $
     . $' /
C    ===================================================================
C
      DATA SBNAME/4HECOB,4HCK  /,IEQ/2HEQ/,ILT/2HLT/
C
      IOLDOP=IOPNUM
      IOPNUM=0
      DO 10 I=1,2
      OLDOPN(I)=OPNAME(I)
   10 OPNAME(I)=SBNAME(I)
C
      IF(ITRACE.GE.1) WRITE(IODBUG,900)
  900 FORMAT(1H0,17H** ECOBCK ENTERED)
C
      LOCAL=FLOCAL
C
      IER=0
      KOUNT=0
      DO 100 J=1,NSLOTS
      CALL FDATCK(ICDAYC(J),ICHRC(J),JDFC,JHFC,IEQ,ISW)
      IF(ISW.EQ.0) GO TO 50
      GO TO 999
C
C   HOLD DATE IN IXDAY ARRAY IF IT IS LESS THAN THE START DATE.
C
   50 CALL FDATCK(ICDAYC(J),ICHRC(J),JDFC,JHFC,ILT,ISW)
      IF(ISW.EQ.0) GO TO 100
      KOUNT=KOUNT+1
      IXDAY(KOUNT)=ICDAYC(J)
      IXTIM(KOUNT)=ICHRC(J)
  100 CONTINUE
      IF(KOUNT.NE.0) GO TO 250
      WRITE(IPR,600)
  600 FORMAT(1H0,10X,47H**ERROR** NO CARRYOVER DATES FOUND AT OR BEFORE,
     1 27H START DATE AND TIME OF RUN)
      IER=2
      CALL KILLFN(8HESP     )
      GO TO 999
C
C   FIND LATEST OF CO DATES BEFORE START.
C
  250 CALL FCOBBL(IXDAY,IXTIM,KOUNT)
      JDFC=IXDAY(KOUNT)
      JHFC=IXTIM(KOUNT)
      CALL MDYH1(JDFC,JHFC,KM,KD,KY,KH,NOUTZ,NOUTDS,TZC)
      WRITE(IPR,605) KM,KD,KY,KH,TZC
  605 FORMAT(1H0,10X,48H**WARNING** THE STARTING DATE AND TIME HAVE BEEN
     1,12H CHANGED TO ,I2,1H/,I2,1H/,I4,1H ,I4,6H HOURS,1X,A4/
     2 23X,57HTHIS CORRESPONDS TO THE CLOSEST CARRYOVER DATE BEFORE THE,
     3 22H REQUESTED START TIME.)
      IER=1
      CALL WARN
C
  999 CONTINUE
C
      LOCAL=0
C
      IOPNUM=IOLDOP
      OPNAME(1)=OLDOPN(1)
      OPNAME(2)=OLDOPN(2)
C
      RETURN
      END
