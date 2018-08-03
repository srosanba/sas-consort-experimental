#Applying an Experimental GTL Feature to Consort Diagrams

##Abstract

SAS added an experimental feature to the TEXTPLOT statement in GTL as part of 9.4 M3. When the OUTLINE option was invoked, this experimental feature allowed the user to capture a dataset with information about where the outline was being drawn using the OUTFILE and OUTID options.

This paper is about the application of the experimental OUTFILE and OUTID options in an attempt to make the creation of CONSORT diagrams a little less labor intensive.

##Layout Inefficiencies

When creating a CONSORT diagram with SAS using the SGPLOT approach, laying out the diagram is rather labor intensive and fiddly. Specifying the coordinates correctly on the first try is virtually impossible. And the dependencies of all of the boxes on one another often causes cascades of side effects when you reposition or resize any one box. Anything that could reduce the amount of time and effort involved in performing the initial layout of the diagram would be useful.

##Experimental Features

As part of 9.4 M3, the options OUTFILE and OUTID were added to the GTL statement TEXTPLOT. Specifying these options result in an output dataset being created with information about where text outlines have been drawn. The idea behind this paper is to leverage the information in this outlines dataset to generate specifications for an initial rough layout for a CONSORT diagram. The goal is not to generate perfect specifications -- that seems a bit unrealistic. But if we can get the positions and sizes of each the boxex even *close* to right, this should speed up the specification process quite a bit.

##Getting Started

The process that I've created to facilitate the initial layout of CONSORT diagrams begins with Excel. This is where you enter your quick and dirty information about the diagram. You need only specify a few key details for each box:

1. A numeric `boxId`.
1. The `row` that the box goes in.
1. The `col` that the box goes in.
1. The `roughText` to be displayed in the box.

<kbd>![excel](https://github.com/srosanba/sas-consort-experimental/blob/master/img/excel.png)</kbd>
