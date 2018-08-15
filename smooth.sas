%let path = H:\GitHub\srosanba\sas-consort-experimental;
ods listing gpath="&path/img";
%let width = 8;
%let height = 6;
%let textsize = 9;

%include "&path/macros/makeboxes.sas";
%include "&path/macros/makelinks.sas";
%include "&path/macros/positiontext.sas";


*--------------------------------------------------------------------------------;
*---------- empty boxes creation ----------;
*--------------------------------------------------------------------------------;

data emptyInfo;
   infile datalines dsd;
   input boxId center top width height;
   *--- the following datalines come from rough.sas log ---;
   datalines;
01,  33.33,  4.31,  25,  4
02,  33.33, 16.59,  25,  4
03,  66.67,  6.51,  32, 12
11,  16.67, 28.88,  32,  9
12,  50.00, 28.88,  32,  9
13,  83.33, 28.88,  32,  9
21,  16.67, 46.43,  32, 15
22,  50.00, 46.43,  32, 15
23,  83.33, 46.43,  32, 15
31,  16.67, 69.22,  32, 12
32,  50.00, 69.22,  32, 12
33,  83.33, 69.22,  32, 12
41,   8.33, 89.39,  11,  7
42,  25.00, 89.39,  11,  7
43,  41.67, 89.39,  11,  7
44,  58.33, 89.39,  11,  7
45,  75.00, 89.39,  11,  7
46,  91.67, 89.39,  11,  7
;
run;

%makeboxes(data=emptyInfo,type=empty);


*--------------------------------------------------------------------------------;
*---------- filled boxes creation ----------;
*--------------------------------------------------------------------------------;

data filledInfo;
   infile datalines dsd;
   input boxId center top width height;
   datalines;
 0, -5, 5, 3,15
10, -5,25, 3,15
20, -5,45, 3,15
30, -5,65, 3,15
40, -5,85, 3,15
;
run;

%makeboxes(data=filledInfo,type=filled);


*--------------------------------------------------------------------------------;
*---------- links creation ----------;
*--------------------------------------------------------------------------------;

data linksInfo;
   infile datalines dsd;
   length fromId toId 8 toEdge $6;
   input fromId toId toEdge $;
   datalines;
 1, 2,
 1, 3,left
 2,11,
 2,12,
 2,13,
 2,14,
11,21,
12,22,
13,23,
14,24,
21,31,
22,32,
23,33,
24,34,
31,41,
31,42,
32,43,
32,44,
33,45,
33,46,
;
run;

%makelinks(dataBoxes=emptyInfo,dataLinks=linksInfo);


*--------------------------------------------------------------------------------;
*---------- position centered horizontal text ----------;
*--------------------------------------------------------------------------------;

data hTextCInfo;
   infile datalines dsd;
   length boxId 8 htextc $50;
   input boxId htextc $;
   datalines;
01,Assessed for Eligibility (n=445)
02,Randomized (n=406)
;
run;

%positiontext
   (dataText=hTextCInfo
   ,dataBoxes=emptyInfo
   ,out=hTextC
   ,justify=c
   );


*--------------------------------------------------------------------------------;
*---------- position left-justfied horizontal text ----------;
*--------------------------------------------------------------------------------;

data hTextLInfo(drop=type n1-n5 arm);
   length type $12 hTextL $125;
   input boxId type $ arm $ 20-27 n1-n5;
   infile datalines missover;
   select (type);
      when ('Enrollment')
         hTextL = cats('Excluded (n=', n1,
            ').* Not meeting inclusion criteria (n=', n2,
            ').* Declined to participate (n=', n3,
            ').* Other reasons (n=', n4, ')'
            );
      when ('Allocation')
         hTextL = cats('Allocated to ', arm, ' (n=', n1,
            ').* Received allocated drug (n=', n2,
            ').* Did not receive allocated drug (n=', n3, ')'
            );
      when ('Follow-Up')
         hTextL = cats('Discontinued drug (n=', n1, ') due to:',
            '.* Adverse events (n=', n2,
            ').* Withdrawn (n=', n3,
            ').* Death (n=', n4, 
            ').* Other (n=', n5, ')'
            );
      when ('Analysis')
         hTextL = cats('FAS (n=', n1,
            ').* Excluded from FAS (n=', n2, 
            ').* Safety set (n=', n3,
            ').* Excluded from SS (n=', n4, ')'
            );
      when ('Good')
         hTextL = cats('Something',
            '.good (n=', n1, ')');
      when ('Bad')
         hTextL = cats('Something',
            '.bad (n=', n1, ')');
      otherwise;
   end;

   datalines;
03     Enrollment          39 22 14 3
11     Allocation  Placebo 95 90 5
12     Allocation  ARM 1   103 103 0
13     Allocation  ARM 2   105 98 7
14     Allocation  ARM 3   102 101 1
21     Follow-Up           10 2 4 0 4
22     Follow-Up           7 3 2 1 1
23     Follow-Up           11 5 2 1 3
24     Follow-Up           16 7 6 2 1
31     Analysis            89 7 90 6
32     Analysis            100 3 103 0
33     Analysis            98 7 98 7
34     Analysis            92 10 101 1
41     Good                98
42     Bad                 1
43     Good                99
44     Bad                 1
45     Good                97
46     Bad                 1
;
run;

%positiontext
   (dataText=hTextLInfo
   ,dataBoxes=emptyInfo
   ,out=hTextL
   ,justify=l
   );


*--------------------------------------------------------------------------------;
*---------- position vertical text ----------;
*--------------------------------------------------------------------------------;

data vTextInfo;
   input boxId vtext $10-75;
   datalines;
00       Enrollment
10       Allocation
20       Follow-Up
30       Analysis
40       Good/Bad
;
run;

%positiontext
   (dataText=vTextInfo
   ,dataBoxes=filledInfo
   ,out=vText
   ,rotate=90
   );


*--------------------------------------------------------------------------------;
*---------- back to regularly scheduled programming ----------;
*--------------------------------------------------------------------------------;

/**
 * Combine all graph data
 */
data consort;
   set 
      linksCoord 
      emptyBoxes
      filledBoxes 
      hTextC 
      hTextL 
      vText
      ;
run;

%let dpi=200;
ods listing image_dpi=&dpi;

/**
 * Draw the Consort Diagram
 */
ods graphics / reset width=&width.in height=&height.in imagename='smooth';
title 'Consort Diagram for a 3 Arm Study';

proc sgplot data=consort noborder noautolegend;
   /* lines connecting boxes, including arrows */
   series x=vX y=vY / group=linkid lineattrs=graphdatadefault
      arrowheadpos=end arrowheadshape=barbed arrowheadscale=0.4;
   /* Empty boxes */
   polygon id=epid x=xEp y=yEp;
   /* Filled boxes */
   polygon id=fpid x=xFp y=yFp / fill outline 
      fillattrs=(color=STGB) lineattrs=(color=VLIGB);
   /* horizontal text, centered */
   text x=xHtc y=yHtc text=hTextC / 
      splitchar='.' splitpolicy =splitalways textattrs=(size=&textsize);
   /* horizontal text, left aligned */
   text x=xHtl y=yHtl text=hTextl / 
      splitchar='.' splitpolicy=splitalways position=right textattrs=(size=&textsize);
   /* vertical text */
   *text x=xVt y=yVt text=vtext / 
      rotate=90 textattrs=(size=9 color=white) textattrs=(size=&textsize);
   /* layout preview */
   *text x=xLayout y=yLayout text=tLayout;
   /* configure axes */
   xaxis display=none min=0 max=100 offsetmin=0 offsetmax=0;
   yaxis display=none min=0 max=100 offsetmin=0 offsetmax=0 reverse;
run
;

ods _all_ close ;

/*** End program ***/