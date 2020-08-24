# ABAP-Search-DB-Views

## What can I do with this program?

A normal development process is write INNER JOINs sentences and a lot of time, SAP have standard DB Views for those accesses.
In this program, you can set the field what do you need in the INNER JOIN and search the existing DB Views in the system.

## How can I install the program?

Clone the repository with [abapGit](https://docs.abapgit.org/) using the [online process](https://docs.abapgit.org/guide-online-install.html) or the [offline process](https://docs.abapgit.org/guide-import-zip.html)

## Can I install it without abapGit?

Yes. You must download the repository, and create the objects manually.
The source code is in the .abap files. The properties and texts, are into the .xml files.

## How can I use this?

You must input the table name and press ENTER to get the table definition in the left ALV.
Check the fields needed and press "Select Fields" button.
Repeat this process with all the tables and fields and then press "Execute".
In the report output, you must see the DB View list.

## Screenshots

Selection Fields\
![Selection Fields](../master/images/selectFields.png?raw=true)

Selection Fields List\
![Selection Fields List](../master/images/selectedFieldList.png?raw=true)

Report Output\
![Report Output](../master/images/reportOutput.png?raw=true)
