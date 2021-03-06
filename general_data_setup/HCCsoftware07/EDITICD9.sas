%MACRO EDITICD9(AGE=, ICD9= );
 %**********************************************************************
 ***********************************************************************

 1  MACRO NAME:      EDITICD9
 2  PURPOSE:         age/sex edits on ICD9 codes
 3  PARAMETERS:      AGE - age variable in a person level file
                     ICD9 - diagnosis variable in a diagnosis file
 **********************************************************************;

    _ICD9_3 = SUBSTR(&ICD9,1,3);    %*first 3 characters from ICD9;
    _ICD9_4 = SUBSTR(&ICD9,1,4);    %*first 4 characters from ICD9;

     %* age restrictions;
     IF &AGE < 18 THEN DO;
        /*emphysema chronic bronchitis */
        IF _ICD9_3 IN ('491','492','496') OR &ICD9 IN ('5181','5182')
        THEN CC='109';
        ELSE
        IF  _ICD9_4 = '4932' THEN  CC='110';
        /*chronic obstructive asthma */
     END;

      %*esophageal atresia/stenosis, oth cong GI anomalies age<2;
      IF &AGE<2 THEN
         IF &ICD9 IN ('7503', '7504', '7507', '7508', '7509', '751',
                      '7515', '7516', '75160','75162','75169','7517',
                      '7518','7519')
         THEN CC='170';

      %* age/sex restrictions;
      SELECT;
        /* males only  */
         WHEN (( '185'<= _ICD9_3 <='187'
                 or _ICD9_3 = '257'
                 or '600'<= _ICD9_3 <='608'
                 or '7525'<=_ICD9_4<='7526'
                 or &ICD9='7528')
               & SEX='2')                                  CC='-1.0';

         /* females only */
         WHEN ( (&ICD9='1121' OR _ICD9_3='131'
                             OR '179'<=_ICD9_3<='184'
                             OR _ICD9_3='256'
                             OR '614'<=_ICD9_3<='627'
                             OR _ICD9_3='629'
                             OR &ICD9='677')
               & SEX='1')                                  CC='-1.0';


        /*Infertility, Pregnancy DXGs Restricted to Females
          Between Ages 8 and 59 */
         WHEN ( (_ICD9_3='628' OR
               '630'<=_ICD9_3<='676' OR
                _ICD9_3 IN ('V22','V23','V24','V27','V28'))
                & (SEX='1' OR &AGE<8 OR &AGE>59))          CC='-1.0';

        /* newborns */
         WHEN((&ICD9 IN ('0900 ','0901 ','0902 ','7485 '
                       '7505 ','7506 ','7511 ','7512 '
                       '7513 ','7514 ','75161','7566 ') OR
              '760' <=_ICD9_3<='770' OR
              '771 ' <=_ICD9_4<='7717' OR
              &ICD9 IN ('7718','77182','77183','77189') OR
              '772' <=_ICD9_3<='779'  OR
              _ICD9_4='V213' OR
              'V29' <=_ICD9_3<='V39')
                &  &AGE>=2)                                CC='-1.0';
         OTHERWISE;
      END; *SELECT;

 %MEND EDITICD9;

