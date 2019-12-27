* Open the topics and contents tables.

#define ccTAB  chr(9)
#define ccCRLF chr(13) + chr(10)
close all
use NEWALLCANDF.DBF order FIXTOPIC alias TOPICS again shared
use CONTENTS order MAIN again shared in 0
set filter to NGROUP <> 0 in TOPICS

* Generate the HHP (project) file. First, the fixed part.

set textmerge on to memvar lcHHP noshow
\\[OPTIONS]
*** Having these two options enables the CHM to be used in the MSDN collection
*** but also messes up the TOC: multi-command docs show the last command name
*** multiple times in the TOC. Also, the wrog image is shown
*\Binary TOC=Yes
*\Create CHI file=Yes
\Compatibility=1.1 or later
\Compiled file=hackfox.chm
\Contents file=hackfox.hhc
\Auto index=Yes
\Default topic=splash.html
\Display compile progress=No
\Full-text search=Yes
\Index file=hackfox.hhk
\Language=0x409 English (United States)
\Title=Hacker's Guide to Visual FoxPro 7.0
\Default Window=HelpWindow
\
\[WINDOWS]
\HelpWindow="Hacker's Guide to Visual FoxPro 7.0","hackfox.hhc","hackfox.hhk","splash.html","cover.html",,,,,0x2520,,0x10384e,,0x10b0000,,,0,,,
\
\[FILES]
\hackfox.css
\bkgnda1.gif
\bkgndatitle.gif

* This is the Easter Egg (search for "magnet near Hentzen", then double-click
* blank item in list)

\friends.html

* This file is used for the background of COVER.HTML.

\fadehackfox.gif

* Output the list of files. During testing, we'll generate a "under
* construction" page for any files that don't exist.

select CONTENTS
scan
	lcFile = trim(FILENAME)
***	ProcessFile(lcFile, lcFile, .T.)
	ProcessFile(lcFile, lcFile)
endscan
select NGROUP from TOPICS where NGROUP > 0 group by 1 into cursor FILES
scan
	lcFile = 's4g' + padl(NGROUP, 3, '0') + '.html'
***	ProcessFile(lcFile, lcFile, .T.)
	ProcessFile(lcFile, lcFile)
endscan
use

* Output the index topics and their IDs.

\
\[ALIAS]
select CONTENTS
scan
	lcFile = trim(FILENAME)
	ProcessFile(lcFile, transform(recno()) + '=' + lcFile)
endscan
select TOPICS
scan
	lcFile = 's4g' + padl(NGROUP, 3, '0') + '.html'
	ProcessFile(lcFile, transform(recno()) + '=' + lcFile)
endscan

* Write out the file.

\
set textmerge to
strtofile(lcHHP, 'HTMLHelp\hackfox.hhp')

* Generate the HHC (contents) file. First, header information.

set textmerge on to memvar lcHHC noshow
\<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
\<HTML>
\<HEAD>
\<meta name="GENERATOR" content="HackFox Laboratories">
\<!-- Sitemap 1.0 -->
\</HEAD>
\<BODY>
\<OBJECT type="text/site properties">
\	<param name="FrameName" value="Right">
\	<param name="SaveType" value="FoxPro 2.x or earlier">
\	<param name="SaveTypeDesc" value="Commands and functions in the language prior to Visual FoxPro">
\	<param name="SaveType" value="Visual FoxPro 3.0">
\	<param name="SaveTypeDesc" value="Commands and functions introduced with Visual FoxPro 3.0">
\	<param name="SaveType" value="Visual FoxPro 5.0">
\	<param name="SaveTypeDesc" value="Commands and functions introduced in Visual FoxPro 5.0">
\	<param name="SaveType" value="Visual FoxPro 6.0">
\	<param name="SaveTypeDesc" value="Commands and functions introduced in Visual FoxPro 6.0">
\	<param name="SaveType" value="Visual FoxPro 6.0, Service Pack 3">
\	<param name="SaveTypeDesc" value="Commands and functions introduced in VFP 6, SP 3">
\	<param name="SaveType" value="Visual FoxPro 7.0">
\	<param name="SaveTypeDesc" value="Commands and functions introduced in Visual FoxPro 7.0">
\	<param name="SaveType" value="dBASE Command">
\	<param name="SaveTypeDesc" value="Commands and functions in the language prior to Visual FoxPro">
\	<param name="Category" value="Version Introduced">
\	<param name="CategoryDesc" value="The version of FoxPro where this command or function was introduced">
\	<param name="Type" value="FoxPro 2.x or earlier">
\	<param name="TypeDesc" value="Commands and functions in the language prior to Visual FoxPro">
\	<param name="Type" value="Visual FoxPro 3.0">
\	<param name="TypeDesc" value="Commands and functions introduced with Visual FoxPro 3.0">
\	<param name="Type" value="Visual FoxPro 5.0">
\	<param name="TypeDesc" value="Commands and functions introduced in Visual FoxPro 5.0">
\	<param name="Type" value="Visual FoxPro 6.0">
\	<param name="TypeDesc" value="Commands and functions introduced in Visual FoxPro 6.0">
\	<param name="Type" value="Visual FoxPro 6.0, Service Pack 3">
\	<param name="TypeDesc" value="Commands and functions introduced in VFP 6, SP 3">
\	<param name="Type" value="Visual FoxPro 7.0">
\	<param name="TypeDesc" value="Commands and functions introduced in Visual FoxPro 7.0">
\	<param name="Type" value="dBASE Command">
\	<param name="TypeDesc" value="Commands and Functions in the language prior to Visual FoxPro">
\	<param name="Background" value="0xffffff">
\	<param name="Foreground" value="0x0">
\	<param name="Window Styles" value="0x800025">
\	<param name="ImageType" value="Folder">
\	<param name="Font" value="Arial,8,1">
\</OBJECT>
\<UL>

* Next, the topics in sections 0-3.

select CONTENTS
lnSection = 0
scan for SECTION < 4

* Finish off the previous section.

	if SECTION <> lnSection
		\	</UL>
		lnSection = SECTION
	endif SECTION <> lnSection

* Create the information for the current file.

	lcFile    = trim(FILENAME)
	lcPrefix1 = ccTAB + iif(PARENT, '', ccTAB)
	lcPrefix2 = ccTAB + lcPrefix1
	lcOutput  = lcPrefix1 + '<LI><OBJECT type="text/sitemap">' + ccCRLF + ;
			lcPrefix2 + '<param name="Name" value="' + ;
				ConvertTitle(NAME) + '">' + ccCRLF + ;
			lcPrefix2 + '<param name="Local" value="' + ;
				lcFile + '">' + ccCRLF + ;
			iif(empty(IMAGE), '', lcPrefix2 + '<param name="ImageNumber" ' + ;
				'value="' + transform(IMAGE) + '">' + ccCRLF) + ;
			lcPrefix1 + '</OBJECT>' + ;
			iif(PARENT, ccCRLF + lcPrefix1 + '<UL>', '')
	ProcessFile(lcFile, lcOutput)
endscan
\	</UL>

* Now generate Section 4 topics from the topics table.

\	<LI><OBJECT type="text/sitemap">
\		<param name="Name" value="Visual FoxPro Reference">
\		<param name="Local" value="s4cover.html">
\		<param name="ImageNumber" value="5">
\	</OBJECT>
\	<UL>
select TOPICS
scan

* Determine the appropriate version information.

	do case
		case VERSION = '2.x' or VERSION = 'FP2x'
			lcVersion = 'FoxPro 2.x or earlier'
		case VERSION = '3.0'
			lcVersion = 'Visual FoxPro 3.0'
		case VERSION = '5.0'
			lcVersion = 'Visual FoxPro 5.0'
		case VERSION = '6.0'
			lcVersion = 'Visual FoxPro 6.0'
		case VERSION = 'SP3'
			lcVersion = 'Visual FoxPro 6.0, Service Pack 3'
		case VERSION = '7'
			lcVersion = 'Visual FoxPro 7.0'
		case VERSION = 'DB'
			lcVersion = 'dBASE Command'
		case VERSION = 'XXX'
			lcVersion = ''
		otherwise
			wait window 'Version ' + VERSION + ' for ' + transform(NGROUP)
			lcVersion = ''
	endcase

* Create the information for the current file.

	lcFile    = 's4g' + padl(NGROUP, 3, '0') + '.html'
	lcPrefix1 = ccTAB + ccTAB
	lcPrefix2 = ccTAB + lcPrefix1
	lcImage   = iif(CHANGED or VERSION = '7', '12', '11')
	lcOutput  = lcPrefix1 + '<LI><OBJECT type="text/sitemap">' + ccCRLF + ;
			lcPrefix2 + '<param name="Name" value="' + ConvertTitle(TOPIC) + ;
				'">' + ccCRLF + ;
			iif(empty(lcVersion), '', lcPrefix2 + '<param name="Type" ' + ;
				'value="Version Introduced::' + lcVersion + '">' + ccCRLF) + ;
			lcPrefix2 + '<param name="Local" value="' + lcFile + '">' + ;
				ccCRLF + ;
			lcPrefix2 + '<param name="ImageNumber" value="' + lcImage + ;
				'">' + ccCRLF + ;
			lcPrefix1 + '</OBJECT>'
	ProcessFile(lcFile, lcOutput)
endscan
\	</UL>

* Finally, create the Section 5 and 6 topics and finish off the file.

select CONTENTS
lnSection = 5
scan for SECTION > 4

* Finish off the previous section.

	if SECTION <> lnSection
		\	</UL>
		lnSection = SECTION
	endif SECTION <> lnSection

* Handle the parent and other topics in the section differently.

	lcFile    = trim(FILENAME)
	lcPrefix1 = ccTAB + iif(PARENT, '', ccTAB)
	lcPrefix2 = ccTAB + lcPrefix1
	lcOutput  = lcPrefix1 + '<LI><OBJECT type="text/sitemap">' + ccCRLF + ;
			lcPrefix2 + '<param name="Name" value="' + ;
				ConvertTitle(NAME) + '">' + ccCRLF + ;
			lcPrefix2 + '<param name="Local" value="' + ;
				lcFile + '">' + ccCRLF + ;
			iif(empty(IMAGE), '', lcPrefix2 + '<param name="ImageNumber" ' + ;
				'value="' + transform(IMAGE) + '">' + ccCRLF) + ;
			lcPrefix1 + ccTAB + '</OBJECT>' + ;
			iif(PARENT, ccCRLF + lcPrefix2 + '<UL>', '')
	ProcessFile(lcFile, lcOutput)
endscan

* Finish off the file and write it out.

\	</UL>
\</UL>
\</BODY>
\</HTML>
\
set textmerge to
strtofile(lcHHC, 'HTMLHelp\hackfox.hhc')

* Generate the HHK (index) file.

set textmerge on to memvar lcHHK noshow
\<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
\<HTML>
\<HEAD>
\<meta name="GENERATOR" content="HackFox Laboratories">
\<!-- Sitemap 1.0 -->
\</HEAD>
\<BODY>
\<UL>

* Now generate Section 4 topics from the topics table. The "param name="Name"
* statement is used twice because HTML Help Workshop requires it.

select TOPICS
scan
	lcTitle   = ConvertTitle(TOPIC)
	lcFile    = 's4g' + padl(NGROUP, 3, '0') + '.html'
	lcPrefix1 = ccTAB
	lcPrefix2 = lcPrefix1 + lcPrefix1
	lcOutput  = lcPrefix1 + '<LI><OBJECT type="text/sitemap">' + ccCRLF + ;
			lcPrefix2 + '<param name="Name" value="' + lcTitle + '">' + ;
				ccCRLF + ;
			lcPrefix2 + '<param name="Name" value="' + lcTitle + '">' + ;
				ccCRLF + ;
			lcPrefix2 + '<param name="Local" value="' + lcFile + '">' + ;
				ccCRLF + ;
			lcPrefix1 + ccTAB + '</OBJECT>' + ccCRLF
	ProcessFile(lcFile, lcOutput)
endscan

* Finish off the file and write it out.

\</UL>
\</BODY>
\</HTML>
\
set textmerge to
strtofile(lcHHK, 'HTMLHelp\hackfox.hhk')

* Now compile it.

erase log.txt
run \progra~1\htmlhe~1\hhc.exe htmlhelp\hackfox.hhp > log.txt
if file('log.txt')
	modify file log.txt
endif file('log.txt')

* Convert illegal characters in topic titles.

function ConvertTitle(tcTitle)
local lcTitle
lcTitle = strtran(trim(tcTitle), '&', '&amp;')
lcTitle = strtran(trim(lcTitle), '"', '&quot;')
lcTitle = strtran(trim(lcTitle), chr(151), '--')
return lcTitle

* Output the file information and create an "under construction" file if it
* doesn't exist.

function ProcessFile(tcFile, tcOutput, tlCreateFile)
\<<tcOutput>>
if tlCreateFile and not file('HTMLHelp\' + tcFile)
	copy file HTMLHelp\UnderConstruction.html to ('HTMLHelp\' + tcFile)
endif tlCreateFile ...
