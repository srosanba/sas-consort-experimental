%let path = H:\GitHub\srosanba\sas-consort-experimental;
%let width = 8;
%let height = 6;


*--------------------------------------------------------------------------------;
*---------- start with rough row/col layout ----------;
*--------------------------------------------------------------------------------;

proc import
      file = "&path\rough.xlsx"
      out = rough00
      dbms = xlsx
      replace
      ;
   sheet = "rowCol";
run;

proc sql noprint;
   select   max(row)
   into     :maxrow
   from     rough00
   where    row = round(row)
   ;
   %let maxrow=&maxrow;
   %put &=maxrow;
   select   max(col)
   into     :maxcol
   from     rough00
   where    col = round(col)
   ;
   %let maxcol=&maxcol;
   %put &=maxcol;
quit;

data rough10;
   set rough00;
   roughx = 100 * (col/(&maxcol+1));
   roughy = 100 * (row/(&maxrow+1));
run;

data dummy10;
   dummyx = 0;
   dummyy = 0;
   output;
   dummyx = 100;
   dummyy = 100;
   output;
run;

data plot10;
   set rough10 dummy10;
run;

ods graphics / 
   reset=all
   outputfmt=png
   width=&width.in
   height=&height.in 
   imagename="rough"
   ;

ods listing 
   gpath="&path" 
   ;
   
proc template;
   define statgraph outfile;
      begingraph / pad=0.01in;
         layout overlay /
               xaxisopts=(
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &width))
                  ) 
               yaxisopts=(
                  reverse=true 
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &height))
                  ) 
               ;
            *--- use dummy values to force desired dimensions ---;
            ScatterPlot X=dummyx Y=dummyy / 
               subpixel=off primary=true 
               LegendLabel="dummyy" NAME="SCATTER"
               ;
            *--- write text and draw box around it, saving box dimensions in CSV file ---;
            TextPlot X=roughx Y=roughy text=roughText / 
               LegendLabel="texty" NAME="TEXT" 
               position=center splitpolicy=splitalways SplitChar="~" 
               Display=(Outline) 
               OutFile="&path/rough.csv" OutID=boxId
               ;
         endlayout;
      endgraph;
   end;
run;

proc sgrender data=plot10 template=outfile;
run;


*--------------------------------------------------------------------------------;
*---------- use rough coordinates to refine y positioning ----------;
*--------------------------------------------------------------------------------;

proc import
      file = "&path/rough.csv"
      out = outfile00 (keep=outid data: rename=(outid=boxId))
      dbms = csv
      replace
      ;
run;

data rough20;
   merge rough10 outfile00;
   by boxId;
run;

proc sql noprint;
   select   distinct row
   into     :rows separated by ' '
   from     rough20
   where    row = round(row)
   ;
   %put &=rows;
quit;

proc sql noprint;
   create   table maxdataheight as
   select   row, max(dataheight) as maxdataheight
   from     rough20
   where    row in (&rows)
   group by row
   ;
   select   sum(maxdataheight) as sumheight
   into     :sumheight
   from     maxdataheight
   ;
   %put &=sumheight;
quit;

proc sort data=rough20 out=rough25;
   by row col;
run;

data row10;
   set rough25;
   by row;
   if first.row and row = round(row);
   retain bettery usedheight 0;
   gapheight = (100-&sumheight)/(&maxrow);
   if row = 1 then do;
      bettery = gapheight/2 + dataheight/2;
      usedheight = usedheight + gapheight/2 + dataheight;
   end;
   else do;
      bettery = usedheight + gapheight + dataheight/2;
      usedheight = usedheight + gapheight + dataheight;
   end;
   keep gapheight row bettery;
run;

proc transpose data=row10 out=trow10 prefix=row;
   by gapheight;
   id row;
   var bettery;
run;

data rough30;
   set rough25;
   if _N_ = 1 then
      set trow10;
   array br {&maxrow} row1-row&maxrow;
   do i = 1 to &ydim-1;
      if row = i then
         bettery = br[i];
   end;
   if missing(bettery) then do;
      prev = floor(row);
      next = ceil(row);
      bettery = (row-prev)*br[prev] + (next-row)*br[next];
   end;
run;

data plot30;
   set rough30 dummy10;
run;

ods graphics / 
   reset=all
   outputfmt=png
   width=&width.in
   height=&height.in 
   imagename="bettery"
   ;

ods listing 
   gpath="&path" 
   ;
   
proc template;
   define statgraph bettery;
      begingraph / pad=0.01in;
         layout overlay /
               xaxisopts=(
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &width))
                  ) 
               yaxisopts=(
                  reverse=true 
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &height))
                  ) 
               ;
            *--- use dummy values to force desired dimensions ---;
            ScatterPlot X=dummyx Y=dummyy / 
               subpixel=off primary=true 
               LegendLabel="dummyy" NAME="SCATTER"
               ;
            *--- write text and draw box around it, saving box dimensions in CSV file ---;
            TextPlot X=roughx Y=bettery text=roughText / 
               LegendLabel="texty" NAME="TEXT" 
               position=center splitpolicy=splitalways SplitChar="~" 
               Display=(Outline) 
               OutFile="&path/rough.csv" OutID=boxId
               ;
         endlayout;
      endgraph;
   end;
run;

proc sgrender data=plot30 template=bettery;
run;


*--------------------------------------------------------------------------------;
*---------- use rough coordinates to refine x positioning ----------;
*--------------------------------------------------------------------------------;

proc sql noprint;
   select   distinct col
   into     :cols separated by ' '
   from     rough20
   where    col = round(col)
   ;
   %put &=cols;
quit;

proc sql noprint;
   create   table maxdatawidth as
   select   col, max(datawidth) as maxdatawidth
   from     rough20
   where    col in (&cols)
   group by col
   ;
   select   sum(maxdatawidth) as sumwidth
   into     :sumwidth
   from     maxdatawidth
   ;
   %put &=sumwidth;
quit;

proc sort data=rough30 out=rough35;
   by col row;
run;

data col10;
   set rough35;
   by col;
   if first.col and col = round(col);
   retain bettery usedwidth 0;
   gapwidth = (100-&sumwidth)/(&maxcol);
   if col = 1 then do;
      betterx = gapwidth/2 + datawidth/2;
      usedwidth = usedwidth + gapwidth/2 + datawidth;
   end;
   else do;
      betterx = usedwidth + gapwidth + datawidth/2;
      usedwidth = usedwidth + gapwidth + datawidth;
   end;
   keep gapwidth col betterx;
run;

proc transpose data=col10 out=tcol10 prefix=col;
   by gapwidth;
   id col;
   var betterx;
run;

%let bcdim = %eval(&maxcol+1);
%put &=bcdim;

data rough40;
   set rough35;
   if _N_ = 1 then
      set tcol10;
   zero = 0 - gapwidth/2 - &sumwidth/&maxcol/2;
   hundo = 100 + gapwidth/2 + &sumwidth/&maxcol/2;
   array bc {0:&bcdim} zero col1-col&maxcol hundo;
   do i = 0 to &bcdim;
      if col = i then
         betterx = bc[i];
   end;
   if missing(betterx) then do;
      prev = floor(col);
      next = ceil(col);
      betterx = (col-prev)*bc[next] + (next-col)*bc[prev];
   end;
run;

data plot40;
   set rough40 dummy10;
run;

ods graphics / 
   reset=all
   outputfmt=png
   width=&width.in
   height=&height.in 
   imagename="betterx"
   ;

ods listing 
   gpath="&path" 
   ;
   
proc template;
   define statgraph betterx;
      begingraph / pad=0.01in;
         layout overlay /
               xaxisopts=(
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &width))
                  ) 
               yaxisopts=(
                  reverse=true 
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &height))
                  ) 
               ;
            *--- use dummy values to force desired dimensions ---;
            ScatterPlot X=dummyx Y=dummyy / 
               subpixel=off primary=true 
               LegendLabel="dummyy" NAME="SCATTER"
               ;
            *--- write text and draw box around it, saving box dimensions in CSV file ---;
            TextPlot X=betterx Y=bettery text=roughText / 
               LegendLabel="texty" NAME="TEXT" 
               position=center splitpolicy=splitalways SplitChar="~" 
               Display=(Outline) 
               OutFile="&path/rough.csv" OutID=boxId
               ;
         endlayout;
      endgraph;
   end;
run;

proc sgrender data=plot40 template=betterx;
run;


*--------------------------------------------------------------------------------;
*---------- final adjustments ----------;
*--------------------------------------------------------------------------------;

proc sort data=rough40 out=final;
   by boxId;
run;

data final;
   set final;
   finalx = round(betterx, .01);
   finaly = round(bettery - dataheight/2, .01);
   finalwidth = round(datawidth, .01);
   finalheight = round(dataheight, .01);
run;

data plotfinal;
   set final dummy10;
run;

ods graphics / 
   reset=all
   outputfmt=png
   width=&width.in
   height=&height.in 
   imagename="final"
   ;

ods listing 
   gpath="&path" 
   ;
   
proc template;
   define statgraph final;
      begingraph / pad=0.01in;
         layout overlay /
               xaxisopts=(
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &width))
                  ) 
               yaxisopts=(
                  reverse=true 
                  display=none
                  offsetmin=0 offsetmax=0 
                  type=linear 
                  linearopts=(tickvaluelist=(0 &height))
                  ) 
               ;
            *--- use dummy values to force desired dimensions ---;
            ScatterPlot X=dummyx Y=dummyy / 
               subpixel=off primary=true 
               LegendLabel="dummyy" NAME="SCATTER"
               ;
            *--- write text and draw box around it, saving box dimensions in CSV file ---;
            TextPlot X=finalx Y=finaly text=roughText / 
               LegendLabel="texty" NAME="TEXT" 
               position=bottom splitpolicy=splitalways SplitChar="~" 
               Display=(Outline) 
               OutFile="&path/rough.csv" OutID=boxId
               ;
         endlayout;
      endgraph;
   end;
run;

proc sgrender data=plotfinal template=final;
run;


*--------------------------------------------------------------------------------;
*---------- copy from log to kick-start SGPLOT approach ----------;
*--------------------------------------------------------------------------------;

data _null_;
   set final;
   format boxId 2. finalx finaly finalwidth finalheight 6.2;
   length putstring $100;
   putstring = cat
      (put(boxId,z2.)
      ,", "
      ,put(finalx,6.2)
      ,","
      ,put(finaly,6.2)
      ,", "
      ,put(finalwidth,6.2)
      ,","
      ,put(finalheight,6.2)
      );
   put putstring;
run;