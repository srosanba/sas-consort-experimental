%macro makelinks(dataBoxes=,dataLinks=);

   *---------- documentation ----------;
   /*
   This macro works in conjunction with %makeboxes. 
   It requires two input datasets: 
   1. dataBoxes: contains the center, top, width, and height of each box
   2. dataLinks: contains Id pairs to be linked
   
   The dataLinks dataset must have the following 3 variables:
   1. fromId: the boxId from which the link originates
         assumes the link originates from the bottom of the fromId box
   2. toId: the boxId to which the link inserts
         assumes the link inserts into the top of the toId box
   3. toEdge: indicate "left" if the link should instead insert into the
         left edge fo the box
         
   The macro creates an output dataset named linksCoord.
   Each record corresponds to a vertex in a link. 
   The dataset contains 3 variables:
   1. linkId: something to number the links with
   2. vX: x coordinate of link vertex
   3. vY: y coordinate of link vertex
   */
   
   *---------- establish coordinates of bottom, top, and left of each box ----------;
   
   data  bottom (keep=boxId xbottom ybottom) 
         top (keep=boxId xtop ytop) 
         left (keep=boxId xleft yleft)
         ;
      set &dataBoxes;
      *--- bottom ---;
      xbottom = center;
      ybottom = top + height;
      output bottom;
      *--- top ---;
      xtop = center;
      ytop = top;
      output top;
      *--- left ---;
      xleft = center - 0.5*width;
      yleft = top + 0.5*height;
      output left;
   run;
   
   *---------- merge bottom coordinates with fromId values ----------;

   proc sort data=&dataLinks out=linksInfo10;
      by fromId;
   run;
   
   proc sort data=bottom out=bottom10 (rename=(boxId=fromId));
      by boxId;
   run;
   
   data linksInfo15;
      merge linksInfo10 (in=links) bottom10;
      by fromId;
      if links;
   run;
   
   *---------- merge top and left coordinates with toId values ----------;

   proc sort data=linksInfo15 out=linksInfo20;
      by toId;
   run;
   
   proc sort data=top out=top20 (rename=(boxId=toId));
      by boxId;
   run;
   
   proc sort data=left out=left20 (rename=(boxId=toId));
      by boxId;
   run;
   
   data linksInfo30;
      merge linksInfo20 (in=links) top20 left20;
      by toId;
      if links;
   run;
   
   *---------- create link vertices ----------;
   
   data linksCoord;
      set linksInfo30;
      linkId + 1;
      *--- originate link out bottom of from box ---;
      vX = xbottom;
      vY = ybottom;
      output;
      *--- if going left ---;
      if toEdge = "left" then do;
         * make an elbow ;
         vX = xbottom;
         vY = yleft;
         output;
         * finish ;
         vX = xleft;
         vY = yleft;
         output;
      end;
      *--- if going down ---;
      else do;
         * elbow left or right ;
         vX = xbottom;
         vY = mean(ybottom,ytop);
         output;
         * elbow down ;
         vX = xtop;
         vY = mean(ybottom,ytop);
         output;
         * finish ;
         vX = xtop;
         vY = ytop;
         output;
      end;
   run;
   
%mend makelinks;