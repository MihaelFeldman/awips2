C MEMBER PRTVAL
C  (from old member LOOKNSET)
C-----------------------------------------------------------------------
C
      SUBROUTINE PRTVAL (IUNIT,NREC,IOPT,ISIZE,ILENTH,I4BUF,I2BUF,L1BUF,
     *   NWORD1,NWORD2,R4BUF,R2BUF,R1BUF)
C
      INTEGER*4 I4BUF(1)
      INTEGER*2 I2BUF(1)
      LOGICAL*1 L1BUF(1)
      REAL R4BUF(1),R2BUF(1),R1BUF(1)
C
C    ================================= RCS keyword statements ==========
      CHARACTER*68     RCSKW1,RCSKW2
      DATA             RCSKW1,RCSKW2 /                                 '
     .$Source: /fs/hseb/ob72/rfc/util/src/looknset/RCS/prtval.f,v $
     . $',                                                             '
     .$Id: prtval.f,v 1.1 1995/09/17 19:00:11 dws Exp $
     . $' /
C    ===================================================================
C
C
C
      IF (IOPT.EQ.1.OR.IOPT.EQ.2) GO TO 60
C
C  PRINT AS REAL
      IF (ISIZE.EQ.2) GO TO 30
      WRITE (IUNIT,10) NREC,NWORD1,NWORD2
10    FORMAT (' CONTENTS OF RECORD ',I6,', WORDS ',I6,' THRU ',I6,
     *   ', IN 10(1X,F5.1) FORMAT')
      IF (ILENTH.EQ.4) WRITE (IUNIT,20) (R4BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.2) WRITE (IUNIT,20) (R2BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.1) WRITE (IUNIT,20) (R1BUF(N),N=NWORD1,NWORD2)
20    FORMAT (10(1X,F5.1))
      GO TO 60
C
30    WRITE (IUNIT,40) NREC,NWORD1,NWORD2
40    FORMAT (' CONTENTS OF RECORD ',I6,', WORDS ',I6,' THRU ',I6,
     *   ', IN 5(1X,F10.3) FORMAT')
      IF (ILENTH.EQ.4) WRITE (IUNIT,50) (R4BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.2) WRITE (IUNIT,50) (R2BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.1) WRITE (IUNIT,50) (R1BUF(N),N=NWORD1,NWORD2)
50    FORMAT (5(1X,F10.3))
C
60    IF (IOPT.EQ.3.OR.IOPT.EQ.4) GO TO 120
C
C  PRINT AS INTEGER
      IF (ISIZE.EQ.2) GO TO 90
      WRITE (IUNIT,70) NREC,NWORD1,NWORD2
70    FORMAT (' CONTENTS OF RECORD ',I6,', WORDS ',I6,' THRU ',I6,
     *   ', IN 10(1X,I5) FORMAT')
      IF (ILENTH.EQ.4) WRITE (IUNIT,80) (I4BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.2) WRITE (IUNIT,80) (I2BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.1) WRITE (IUNIT,80) (L1BUF(N),N=NWORD1,NWORD2)
80    FORMAT (10(1X,I5))
      GO TO 120
C
90    WRITE (IUNIT,100) NREC,NWORD1,NWORD2
100   FORMAT (' CONTENTS OF RECORD ',I6,', WORDS ',I6,' THRU ',I6,
     *   ', IN 5(1X,I10) FORMAT')
      IF (ILENTH.EQ.4) WRITE (IUNIT,110) (I4BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.2) WRITE (IUNIT,110) (I2BUF(N),N=NWORD1,NWORD2)
      IF (ILENTH.EQ.1) WRITE (IUNIT,110) (L1BUF(N),N=NWORD1,NWORD2)
110   FORMAT (5(1X,I10))
C
120   IF (IOPT.EQ.1.OR.IOPT.EQ.3.OR.IOPT.EQ.5) GO TO 150
C
C  PRINT AS CHARACTERS
C
      WRITE (IUNIT,130) NREC,NWORD1,NWORD2
130   FORMAT (' CONTENTS OF RECORD ',I6,', WORDS ',I6,' THRU ',I6,
     *   ', IN 10(1X,A4) FORMAT')
        II = (NWORD1-1)*ILENTH + 1
        JJ = NWORD2*ILENTH
      IF (ILENTH.EQ.4) CALL PRTASC(IUNIT,I4BUF,II,JJ)
      IF (ILENTH.EQ.2) CALL PRTASC(IUNIT,I2BUF,II,JJ)
      IF (ILENTH.EQ.1) CALL PRTASC(IUNIT,L1BUF,II,JJ)
C
150   RETURN
C
      END
