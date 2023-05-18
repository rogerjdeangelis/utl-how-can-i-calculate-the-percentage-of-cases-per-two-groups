%let pgm=utl-how-can-i-calculate-the-percentage-of-cases-per-two-groups;

StackOverfloe R
https://tinyurl.com/4udkmm67
https://stackoverflow.com/questions/76237289/how-can-i-calculate-the-percentage-of-cases-per-two-groups

Calculate the percentage of cases per two groups?
Not sure the SQL soltions are generl soltions, you may have to make minor
changes based on more relistic data.

         Solution

           1. WPS R native
           2. WPS/SAS SQL
           3. WPS R sql
           4. Python sql
/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/
options validvarname=upcase;
data have;informat
SUBJECT $1.
ITEM 8.
GROUP $4.
;input
SUBJECT ITEM GROUP;
cards4;
A 1 pre
A 2 pre
A 3 pre
B 1 pre
B 4 pre
B 5 pre
C 1 post
C 2 post
C 6 post
D 3 post
D 4 post
D 7 post
;;;;
run;quit;

proc sort data=have;
  by subject group ;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*              HAVE             |  STEP 1 Add Number    |  STEP 2 add distinct count        | STEP 3  Fill  with 0       */
/*                               |  of subject per group |   item x group subGrpCnt          | could also use proc freq   */
/*                               |                       |                                   | sparse  WANT               */
/* Obs  SUBJECT    GROUP   ITEM  | subGrpCnt             |  ITEM  SUBGRPPCT                  | ITEM    GROUP    SUBGRPPCT */
/*                               |                       |                                   |                            */
/*   1     A       pre       1   |    2  subjects A & B  |    1       50                     |   1     post         50    */
/*   2     A       pre       2   |    2  for group pre   |    1      100  there are two 2/2  |   1     pre         100    */
/*   3     A       pre       3   |    2                  |    2       50  100%  2 100 x pre  |   1     pre         100    */
/*                               |                       |    2       50  op wants just one  |   2     post         50    */
/*   4     B       pre       1   |    2                  |    3       50                     |   2     pre          50    */
/*   5     B       pre       4   |    2                  |    3       50                     |   3     post         50    */
/*   6     B       pre       5   |    2                  |    4       50                     |   3     pre          50    */
/*                               |                       |    4       50                     |   4     post         50    */
/*   7     C       post      1   |    2  c & d           |    5       50                     |   4     pre          50    */
/*   8     C       post      2   |    2                  |    6       50                     |   5     post          0    */
/*   9     C       post      6   |    2                  |    7       50                     |   5     pre          50    */
/*                               |                       |                                   |   6     post         50    */
/*  10     D       post      3   |    2                  |                                   |   6     pre           0    */
/*  11     D       post      4   |    2                  |                                   |   7     post         50    */
/*  12     D       post      7   |    2                  |                                   |   7     pre           0    */
/*                               |                       |                                   |                            */
/**************************************************************************************************************************/

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* Up to 40 obs from last table WORK.WANT total obs=14 18MAY2023:12:32:43                                                 */
/*                                                                                                                        */
/* Obs    ITEM    GROUP    SUBGRPPCT                                                                                      */
/*                                                                                                                        */
/*   1      1     post         50                                                                                         */
/*   2      1     pre         100                                                                                         */
/*   3      2     post         50                                                                                         */
/*   4      2     pre          50                                                                                         */
/*   5      3     post         50                                                                                         */
/*   6      3     pre          50                                                                                         */
/*   7      4     post         50                                                                                         */
/*   8      4     pre          50                                                                                         */
/*   9      5     post          0                                                                                         */
/*  10      5     pre          50                                                                                         */
/*  11      6     post         50                                                                                         */
/*  12      6     pre           0                                                                                         */
/*  13      7     post         50                                                                                         */
/*  14      7     pre           0                                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                                             _   _
/ |   __      ___ __  ___   _ __   _ __   __ _| |_(_)_   _____
| |   \ \ /\ / / `_ \/ __| | `__| | `_ \ / _` | __| \ \ / / _ \
| |_   \ V  V /| |_) \__ \ | |    | | | | (_| | |_| |\ V /  __/
|_(_)   \_/\_/ | .__/|___/ |_|    |_| |_|\__,_|\__|_| \_/ \___|
               |_|
*/

proc datasets lib=work nodetails nolist;
 delete want_r_native;
run;quit;

%let _pth=%sysfunc(pathname(work));
%utl_submit_wps64('
libname wrk "&_pth";
proc r;
export data=wrk.have r=have;
submit;
library(dplyr);
library(tidyr);
want<-have %>%
  mutate(nsub = n_distinct(SUBJECT, GROUP), .by = GROUP) %>%
  reframe(PERCENT = 100*n()/nsub, .by = c(ITEM, GROUP)) %>%
  distinct_all() %>%
  complete(ITEM, GROUP, fill = list(PERCENT = 0));
want;
endsubmit;
import data=wrk.want_r_native r=want;
run;quit;
');

 /**************************************************************************************************************************/
 /*                                                                                                                        */
 /* Up to 40 obs from WANT_R_NATIVE total obs=14 18MAY2023:12:41:53                                                        */
 /*                                                                                                                        */
 /* Obs    ITEM    GROUP    PERCENT                                                                                        */
 /*                                                                                                                        */
 /*   1      1     post        50                                                                                          */
 /*   2      1     pre        100                                                                                          */
 /*   3      2     post        50                                                                                          */
 /*   4      2     pre         50                                                                                          */
 /*   5      3     post        50                                                                                          */
 /*   6      3     pre         50                                                                                          */
 /*   7      4     post        50                                                                                          */
 /*   8      4     pre         50                                                                                          */
 /*   9      5     post         0                                                                                          */
 /*  10      5     pre         50                                                                                          */
 /*  11      6     post        50                                                                                          */
 /*  12      6     pre          0                                                                                          */
 /*  13      7     post        50                                                                                          */
 /*  14      7     pre          0                                                                                          */
 /*                                                                                                                        */
 /*                                                                                                                        */
 /**************************************************************************************************************************/

/*___                                                     _
|___ \    __      ___ __  ___   ___  __ _ ___   ___  __ _| |
  __) |   \ \ /\ / / `_ \/ __| / __|/ _` / __| / __|/ _` | |
 / __/ _   \ V  V /| |_) \__ \ \__ \ (_| \__ \ \__ \ (_| | |
|_____(_)   \_/\_/ | .__/|___/ |___/\__,_|___/ |___/\__, |_|
                   |_|                                 |_|
*/
proc datasets lib=work nodetails nolist;
 delete want_wpsSAS;
run;quit;

%let _pth=%sysfunc(pathname(work));

%utl_submit_wps64('

options validvarname=any;
libname wrk "&_pth";

proc sql;
  create
    table havsubgrp as
  select
    subject
    ,item
    ,group
    ,count(distinct subject) as subGrpCnt
  from
    wrk.have
  group
    by group
;
  create
    table havItmGrp as
  select
    distinct
     item
    ,group
    ,100*count(*)/subGrpCnt as subGrpPct
  from
    havsubgrp
  group
    by item, group
;
    create
       table wrk.want_wpsSasSql as
    select
       l.item
      ,l.group
      ,coalesce(r.subGrpPct,0) as subGrpPct
    from (
       Select
          distinct
             l.item
           , r.group
       from
          wrk.have l cross join wrk.have as r
       ) as l left join
        havItmGrp as r
    on
           l.item   = r.item
       and l.group  = r.group
;quit;

');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  Up to 40 obs from WRK.WANT_WPSSASSQL total obs=14 18MAY2023:12:50:30                                                  */
/*                            sub                                                                                         */
/*  Obs    ITEM    GROUP    GrpPct                                                                                        */
/*                                                                                                                        */
/*    1      1     post        50                                                                                         */
/*    2      1     pre        100                                                                                         */
/*    3      2     post        50                                                                                         */
/*    4      2     pre         50                                                                                         */
/*    5      3     post        50                                                                                         */
/*    6      3     pre         50                                                                                         */
/*    7      4     post        50                                                                                         */
/*    8      4     pre         50                                                                                         */
/*    9      5     post         0                                                                                         */
/*   10      5     pre         50                                                                                         */
/*   11      6     post        50                                                                                         */
/*   12      6     pre          0                                                                                         */
/*   13      7     post        50                                                                                         */
/*   14      7     pre          0                                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____                                          _
|___ /   __      ___ __  ___   _ __   ___  __ _| |
  |_ \   \ \ /\ / / `_ \/ __| | `__| / __|/ _` | |
 ___) |   \ V  V /| |_) \__ \ | |    \__ \ (_| | |
|____(_)   \_/\_/ | .__/|___/ |_|    |___/\__, |_|
                  |_|                        |_|
*/

/*---- rename variable group ----*/

data havRen;
  set have(rename=group=grp);
run;quit;

proc datasets lib=work nodetails nolist;
 delete want_wpsSasSql;
run;quit;


%let _pth=%sysfunc(pathname(work));

%utl_submit_wps64('

libname wrk "&_pth";

proc r;
export data=wrk.havren  r=have;
submit;
library(sqldf);
havsubgrp <- sqldf("
  select
    l.subject
    ,l.item
    ,l.grp
    ,r.subgrpcnt
  from
    have as l, (
        select grp, count(distinct subject) as subgrpcnt
        from have group by grp) as r
  where
    l.grp = r.grp
  ");

havItmGrp <- sqldf("
  select
    distinct
     item
    ,grp
    ,100*count(*)/subGrpCnt as subGrpPct
  from
    havsubgrp
  group
    by item, grp
  ;
  ");
want_wpsSasSql <- sqldf("
    select
       l.item
      ,l.grp
      ,coalesce(r.subGrpPct,0) as subGrpPct
    from (
       Select
          distinct
             l.item
           , r.grp
       from
          have l cross join have as r
       ) as l left join
        havItmGrp as r
    on
           l.item   = r.item
       and l.grp  = r.grp
    order
       by l.item, r.grp
   ");
want_wpsSasSql;
endsubmit;
import data=wrk.want_wpsSasSql r=want_wpsSasSql;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*        The WPS System            The SAS System                                                                        */
/*                                                                                                                        */
/*      item  grp subGrpPct     Obs    ITEM    GRP     SUBGRPPCT                                                          */
/*   1     1 post        50       1      1     post        50                                                             */
/*   2     1  pre       100       2      1     pre        100                                                             */
/*   3     2 post        50       3      2     post        50                                                             */
/*   4     2  pre        50       4      2     pre         50                                                             */
/*   5     3 post        50       5      3     post        50                                                             */
/*   6     3  pre        50       6      3     pre         50                                                             */
/*   7     4 post        50       7      4     post        50                                                             */
/*   8     4  pre        50       8      4     pre         50                                                             */
/*   9     5 post         0       9      5     post         0                                                             */
/*   10    5  pre        50      10      5     pre         50                                                             */
/*   11    6  pre         0      11      6     pre          0                                                             */
/*   12    6 post        50      12      6     post        50                                                             */
/*   13    7  pre         0      13      7     pre          0                                                             */
/*   14    7 post        50      14      7     post        50                                                             */
/*                                                                                                                        */
/**************************************************************************************************************************/


libname sd1 "d:/sd1";

data sd1.havRen;
  set have(rename=group=grp);
run;quit;

proc datasets lib=work kill nodetails nolist;
run;quit;

%utlfkil(d:/xpt/res.xpt);

%utl_pybegin;
parmcards4;
from os import path
import pandas as pd
import xport
import xport.v56
import pyreadstat
import numpy as np
import pandas as pd
from pandasql import sqldf
mysql = lambda q: sqldf(q, globals())
from pandasql import PandaSQL
pdsql = PandaSQL(persist=True)
sqlite3conn = next(pdsql.conn.gen).connection.connection
sqlite3conn.enable_load_extension(True)
sqlite3conn.load_extension('c:/temp/libsqlitefunctions.dll')
mysql = lambda q: sqldf(q, globals())
have, meta = pyreadstat.read_sas7bdat("d:/sd1/havRen.sas7bdat")
print(have);
havsubgrp = pdsql("""
  select
    l.subject
    ,l.item
    ,l.grp
    ,r.subgrpcnt
  from
    have as l, (
        select grp, count(distinct subject) as subgrpcnt
        from have group by grp) as r
  where
    l.grp = r.grp
""")

havItmGrp = pdsql("""
  select
    distinct
     item
    ,grp
    ,100*count(*)/subGrpCnt as subGrpPct
  from
    havsubgrp
  group
    by item, grp
""")

res = pdsql("""
    select
       l.item
      ,l.grp
      ,coalesce(r.subGrpPct,0) as subPct
    from (
       Select
          distinct
             l.item
           , r.grp
       from
          have l cross join have as r
       ) as l left join
        havItmGrp as r
    on
           l.item   = r.item
       and l.grp  = r.grp
    order
       by l.item, r.grp
""")
print(res);
ds = xport.Dataset(res, name='res')
with open('d:/xpt/res.xpt', 'wb') as f:
    xport.v56.dump(ds, f)
;;;;
%utl_pyend;

libname pyxpt xport "d:/xpt/res.xpt";

proc contents data=pyxpt._all_;
run;quit;

proc print data=pyxpt.res;
run;quit;

data res;
   set pyxpt.res;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  Up to 40 obs from RES total obs=14 18MAY2023:14:17:48                                                                 */
/*                                                                                                                        */
/*        The SAS System               Python                                                                             */
/*                         sub                                                                                            */
/*  Obs    item    grp     Pct                                                                                            */
/*                                      item   grp  subPct                                                                */
/*    1      1     post     50      0    1.0  post      50                                                                */
/*    2      1     pre     100      1    1.0   pre     100                                                                */
/*    3      2     post     50      2    2.0  post      50                                                                */
/*    4      2     pre      50      3    2.0   pre      50                                                                */
/*    5      3     post     50      4    3.0  post      50                                                                */
/*    6      3     pre      50      5    3.0   pre      50                                                                */
/*    7      4     post     50      6    4.0  post      50                                                                */
/*    8      4     pre      50      7    4.0   pre      50                                                                */
/*    9      5     post      0      8    5.0  post       0                                                                */
/*   10      5     pre      50      9    5.0   pre      50                                                                */
/*   11      6     pre       0      10   6.0   pre       0                                                                */
/*   12      6     post     50      11   6.0  post      50                                                                */
/*   13      7     pre       0      12   7.0   pre       0                                                                */
/*   14      7     post     50      13   7.0  post      50                                                                */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
