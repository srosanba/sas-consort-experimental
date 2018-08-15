%macro positiontext(dataText=,dataBoxes=,out=,justify=,rotate=);

   *---------- documentation ----------;
   /*
   This macro works in conjunction with %makeboxes.
   It uses positioning information from the emptyInfo|filledInfo 
   dataset to position text within a box.
   
   Required parameters are:
   1. dataText: dataset containing boxID and text string
   2. dataBoxes: dataset containing box center, top, width, and height
         e.g., emptyInfo, filledInfo
   3. outText: output dataset name
         e.g., hTextC, hTextL, vText
   
   Optional parameters are:
   1. justify: set to l or c for horizontal text
   2. rotate: set to 90 for vertical text
   */
   
   *---------- merge box info onto text dataset ----------;
   
   proc sort data=&dataText out=dt10;
      by boxId;
   run;
   
   proc sort data=&dataBoxes out=db10;
      by boxId;
   run;
   
   data &out;
      merge dt10 (in=dt) db10;
      by boxId;
      if dt;
      if "&rotate" eq "90" then do;
         xVt = center;
         yVt = top + 0.5*height;
      end;
      else do;
         if "&justify" eq "c" then do;
            xHtc = center;
            yHtc = top + 0.5*height;
         end;
         else if "&justify" eq "l" then do;
            xHtl = center - 0.5*width;
            yHtl = top + 0.5*height;
         end;
      end;
   run;

%mend positiontext;