# guidelinesApp
Application running the Guidelines of the Beta maṣāḥǝft project.
These guidelines are written in TEI/XML and the application is a simple eXist-db application using templating and an XSLT transformation for the views.
You can use these for your own guidelines given the same data structure and TEI encoding is used, and either install the package from .xar or clone this repository adding your data.
The schema for these guidelines (tei-betamesaheftGL.xml)  is stored with the data of the Beta maṣāḥǝft Guidelines and can be found here https://github.com/BetaMasaheft/guidelines .
Also the ontology and schema directories are empty as the data is stored elsewhere in the organization.

The page views and the elements and attributes view pull information from the TEI page with that id but also directly from the schema, to integrate the guidelines for encoding practice with all the rules and examples provided directly in the Beta maṣāḥǝft ODD ((tei-betamesaheft.xml)[https://github.com/BetaMasaheft/Schema/blob/master/tei-betamesaheft.xml]).