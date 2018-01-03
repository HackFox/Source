Instructions to Create HackFox.CHM
==================================

Directory structure:
--------------------

- Root directory for project contains all code and tables used:

	- PROCESS.PJX and PJT: used just as a organizer for the files

	- LOOKFORDUPTOPICS.PRG: looks for potentially duplicated topics
	
	- DELDUPES.PRG: looks for and removed duplicated files
	
	- TESTFILES.PRG: looks for missing files
	
	- PROCESS.PRG: generates the HTML files from the Word docs
	
	- CREATECHM.PRG: generates the CHM from the HTML files ASSEMBLE.VCX, VCT, and H: processing classes

	- SFCTRLS.VCX and VCT, SFCTRLS.H, SFCTRLCHAR.H, SFERRORS.H: Stonefield base classes
	
	- SFTHERM.VCX and VCT: progress meter classes
	
	- MAKEOBJECT.PRG: supporting PRG for SFCTRLS classes

	- CONTENTS.DBF and CDX: list of non-S4 topics (used in CHM generation)
	
	- NEWALLCANDF.DBF, FPT, and CDX: list of all S4 topics
	
	- REPLSTRS.DBF and FPT: list of "bad" text to search for
	
	- STATUS.DBF, FPT, and CDX: list of all topics (used to look for duplicated or missing files only)

	- UNDERCON.GIF and UNDERCONSTRUCTION.HTML: used during testing phases as a placeholder for missing documents

- FinalWordDocs subdirectory: contains all final Word docs

- OriginalDocs subdirectory: contains all final Word docs from the previous edition (FinalWordDocs may only have docs changed in this edition)

- Section0: other files, such as graphics, splash and cover HTML files, bios, etc.

The following directories are created and populated during processing:

- WordDocs: the staging area for combined FinalWordDocs and OriginalDocs, with duplicated docs eliminated

- HTMLDocs: the results of saving WordDocs files as HTML

- HTMLHelp: the final directory containing all processed HTML files, all graphic files, and the CHM and HTML Help project files

Instructions
------------

0.	Run ConvertTextToBinary.bat to generate VFP binary files from their text equivalents.

1.	**Already done** Run LOOKFORDUPETOPICS.PRG to find potentially duplicated topics. This will show a list of all topics with similar names (such as the Error method and ERROR command) which may be sources of problems in See Also section of docs. If two topics have the same name, one of them must be renamed (for example, "ERROR" and "Error Method") so there is no collision. PROCESS.PRG will look for and log potentially duplicated topics listed in the See Also sections of all documents; any docs identifies should be examined and changed to the correct topic name as necessary.

2.	**Already done** Put all final documents for this edition into FinalWordDocs and all final documents for the previous edition (unzip S4A.ZIP, S4B.ZIP, S4C.ZIP, and PRINTED.ZIP) into OriginalDocs.
	
3.	**Already done** Put "other files" (unzip OTHERFILES.ZIP) into Section0.

4.	**Already done** Put the latest copies of the NEWALLCANDF and STATUS tables in the root directory of the project.

5.	**Already done** Run TESTFILES.PRG to look for missing files and handle any it identifies.

6.	Delete the contents of HTMLDocs and HTMLFiles (if these directories exist from previous runs).

7.	Set ACTIVE for all records in REPLSTRS.DBF to .T. This will cause all types of "bad" text checks to be performed. During the processing, a log file of all docs contains the "bad" text will be displayed. These docs should be examined and the text corrected if necessary. In some cases, the use of the "bad" text may be legitimate (for example, while "VFP7" with no space shouldn't be used in text, it may be a valid directory name in code), so add the names of those documents (with no extension) to the VALIDDOCS memo (each on a separate line). In later processing runs, set ACTIVE to .F. for those tests that don't need to be run anymore (any docs using the "bad" text have been corrected).

8. Run PROCESS.PRG. This will combine files from OriginalDocs and FinalWordDocs into WordDocs, eliminate duplicates (for example, if S4G006.2DH and S4G006.3TG exist, S4G006.2DH will be deleted from WordDocs), use Word Automation to convert the docs to HTML files in HTMLDocs, then perform processing on those files to create the final HTML files in HTMLHelp. Note: since the Word Automation is the slowest step and the least prone to tweaking, on subsequent runs, if the Word docs haven't changed, you can save time by DO PROCESS WITH .T.; this tells it to skip the HTML generation process and proceed with processing the files in HTMLDocs.

9. Go over the HTML files in HTMLHelp to ensure everything is OK.

10. To generate the CHM, run CREATECHM.PRG.
