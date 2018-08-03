# Applying an Experimental GTL Feature to Consort Diagrams

## Abstract

SAS added an experimental feature to the TEXTPLOT statement in GTL as part of 9.4 M3. When the OUTLINE option was invoked, this experimental feature allowed the user to capture a dataset with information about where the outline was being drawn using the OUTFILE and OUTID options.

This paper is about the application of the experimental OUTFILE and OUTID options in an attempt to make the creation of CONSORT diagrams a little less labor intensive.

## Layout Inefficiencies

When creating a CONSORT diagram with SAS using the SGPLOT approach, laying out the diagram is rather labor intensive and fiddly. Specifying the coordinates correctly on the first try is virtually impossible. And the dependencies of all of the boxes on one another often causes cascades of side effects when you reposition or resize any one box. Anything that could reduce the amount of time and effort involved in performing the initial layout of the diagram would be useful.

## Experimental Features

As part of 9.4 M3, the options OUTFILE and OUTID were added to the GTL statement TEXTPLOT. Specifying these options result in an output dataset being created with information about where text outlines have been drawn. The idea behind this paper is to leverage the information in this outlines dataset to generate specifications for an initial rough layout for a CONSORT diagram. The goal is not to generate perfect specifications -- that seems a bit unrealistic. But if we can get the positions and sizes of each the boxex even *close* to right, this should speed up the specification process quite a bit.

## How It Works

The process that I've created to facilitate the initial layout of CONSORT diagrams begins with Excel. This is where you enter your quick and dirty information about your diagram. You need only specify a four pieces of information for each box:

1. A numeric `boxId`.
1. The `row` that the box goes in.
1. The `col` that the box goes in.
1. The `roughText` to be displayed in the box.

<kbd>![excel](https://github.com/srosanba/sas-consort-experimental/blob/master/img/excel.png)</kbd>

You'll notice a couple of things about these Excel specifications.

* The `roughText` truly is rough.  
  * Having roughly the right length of text strings is much more important than having the exact wording.
* The position of each box is specified with a `row` and `col` pair.  
  * The integer values correspond to the boxes that form the main structure of the diagram. Use integers for boxes that are meant to line up with other boxes.  
  * The non-integer values are for the fiddly bits of the diagram that don't fit nicely into a row or column. Use non-integer values to communicate that a box goes *somewhere over there*.

## Rough Plot

The SAS program reads in the Excel file and creates a really rough draft layout using the `row` and `col` values.

<kbd>![rough](https://github.com/srosanba/sas-consort-experimental/blob/master/img/rough.png)</kbd>

This initial diagram is a throw-away. It's only purpose is to allow us to create the OUTFILE which contains the information about the width and height of each of the outlines that were drawn.

<kbd>![outfile](https://github.com/srosanba/sas-consort-experimental/blob/master/img/outfile.png)</kbd>

Now that we know how tall each of the boxes are, it becomes a simple algebra problem to figure up how much total vertical space the boxes use. We then divide the remaining space up between the rows to equally space the boxes vertically.

<kbd>![bettery](https://github.com/srosanba/sas-consort-experimental/blob/master/img/bettery.png)</kbd>

We also know how wide each of the boxes are, so it is equally as simple to figure up how much total horizontal space the boxes use. We then divide the remaining space up between the columns to equally space the boxes horizontally.

<kbd>![betterx](https://github.com/srosanba/sas-consort-experimental/blob/master/img/betterx.png)</kbd>

Now that we know roughly where the boxes should go, we need to be able to incorporate this information back into the SGPLOT-based process for generating CONSORT diagrams. Fortunately, the SAS program ends with the creation of a `putstring` variable, the content of which can be easily copy/pasted into the `datalines` of the `emptyBoxes` data step in the SGPLOT-based CONSORT diagram program.

<kbd>![putstring](https://github.com/srosanba/sas-consort-experimental/blob/master/img/putstring.png)</kbd>

Note: the above `putstring` assumes you are using the helper macros described in the [sas-consort-sgplot](https://github.com/srosanba/sas-consort-sgplot) repository. If you have yet to adopt these helper macros, the above process will be of little use to you.

## Conclusion

Generating the layout for a CONSORT diagram created with SGPLOT is not trivial. The above process allows the user to quickly generate rough specifications using nothing more than row and column values for positioning. Incorporating this into your CONSORT process should reduce the amount of time spent generating the initial layout.
