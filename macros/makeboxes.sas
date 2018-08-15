%macro makeboxes(data=,type=);

   *---------- documentation ----------;
   /*
   This macro assumes an input dataset with 5 numeric variables:
   1. boxId: something to number the boxes with
   2. center: x coordinate of box's center
   3. top: y coordinate of box's top edge
   4. width: how wide is the box
   5. height: how tall is the box
   The idea is to fully specify a box's size and location in one line.
   
   The macro creates an output dataset named emptyBoxes|filledBoxes. 
   Each record corresponds to a corner of a box, so 4 records per box.
   The dataset contains 3 essential numeric variables:
   1. epId|fpId: empty|filled polygon Id
   2. xEp|xFp: empty|filled x coordinate
   3. yEp|yFp: empty|filled y coordinate
   
   The dataset also contains 3 optional variables which can be used to
   write the box's Id value on the page, for assessing the layout.
   1. xLayout: x coordinate for box's Id
   2. yLayout: y coordinate for box's Id
   3. tLayout: text version of box's Id
   */

   *---------- type-based variable names ----------;
  
   %if &type eq empty %then %do;
      %let idvar = epId;
      %let xvar = xEp;
      %let yvar = yEp;
   %end;
   %else %do;
      %let idvar = fpId;
      %let xvar = xFp;
      %let yvar = yFp;
   %end;
   
   *---------- build dataset &type.Boxes ----------;
   
   data &type.Boxes;
      set &data;
      &idvar = boxId;
      *--- top left ---;
      &xvar = center - 0.5*width;
      &yvar = top;
      output;
      *--- top right ---;
      &xvar = center + 0.5*width;
      &yvar = top;
      output;
      *--- bottom right ---;
      &xvar = center + 0.5*width;
      &yvar = top + height;
      output;
      *--- bottom left and layout helper vars ---;
      &xvar = center - 0.5*width;
      &yvar = top + height;
      xLayout = center;
      yLayout = top + 0.5*height;
      tLayout = strip(put(&idvar,best.));
      output;
      keep &idvar &xvar &yvar xLayout yLayout tLayout;
   run;

%mend makeboxes;