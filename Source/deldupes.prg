*==============================================================================
* Program:			DelDupes.prg
* Purpose:			Delete duplicate Word documents
* Author:			Doug Hennig and Ted Roche
* Last revision:	12/08/2001
* Parameters:		tcDirectory - the location of the Word documents (optional:
*						if it isn't passed, the user is prompted for the
*						location)
*					tcLogFile   - the file to log deletions or conflicts to
*						(optional: if it isn't passed, HackFoxLog.log in the
*						current directory is used)
* Returns:			.T. if no duplicates were found
* Environment in:	none
* Environment out:	duplicate files have been deleted
*					deletions and conflicts are logged in the log file
*==============================================================================

lparameters tcDirectory, ;
	tcLogFile
local lcDir, ;
	lcLogFile, ;
	laFiles[1], ;
	lnFileCount, ; 
	lcFileName, ;
	llLog, ;
	lnI, ;
	lcThisFile

* Handle the directory and/or log file not passed.

lcDir = iif(vartype(tcDirectory) = 'C' and not empty(tcDirectory) and ;
	directory(tcDirectory), tcDirectory, getdir('', '', 'Locate Word Files'))
if empty(lcDir)
	return .F.
endif empty(lcDir)
lcDir     = addbs(lcDir)
lcLogFile = iif(vartype(tcLogFile) = 'C' and not empty(tcLogFile), tcLogFile, ;
	'HackFoxLog.log')

* Get a list of files in the specified directory (this assumes the directory
* contains nothing but the Word files).

lnFileCount = adir(laFiles, lcDir + '*.*')
asort(laFiles)

* Start textmerge to the log file.

set textmerge on to (lcLogFile) noshow

* Look for duplicates in the stem of the file name. There are two types: those
* where one version is older (eg. S4G001.0TG and S4G001.1DH), in which case the
* older one is eliminated, and where two have the same version number (eg.
* S4G001.0TG and S4G001.0DH), in which case the conflict is just logged. 

lcFileName = laFiles[1, 1]
llLog      = .F.
for lnI = 2 to lnFileCount
	lcThisFile = laFiles[lnI, 1]
	do case
		case not juststem(lcThisFile) == juststem(lcFileName)
		case left(justext(lcThisFile), 1) == left(justext(lcFileName), 1)
			\Conflict: <<lcFileName>> or <<lcThisFile>>
			llLog = .T.
		otherwise
			\Delete <<lcFileName>>, retain <<lcThisFile>>
			erase (lcDir + lcFileName)
			llLog = .T.
	endcase
	lcFileName = lcThisFile
next lnI

* Close the log file.

if llLog
	\
endif llLog
set textmerge to
return not llLog
