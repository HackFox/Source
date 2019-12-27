#define ccCRLF chr(13) + chr(10)

lcOutputDir = '..\Section4\'
erase log.txt

* Get all the S4G files.

lcHTMLFolder = 'HTMLForMarkdown\'
lnFiles = adir(laFiles, lcHTMLFolder + 's4g*.html')
for lnI = 1 to lnFiles
	lcFile = lower(laFiles[lnI, 1])
	if lcFile <> 's4g000.html'
if '902' $ juststem(lcFile)
		lcHTML = filetostr(lcHTMLFolder + lcFile)
		lcHTML = HTMLToMarkdown(lcHTML)
		lcFile = lcOutputDir + juststem(lcFile) + '.md'
		strtofile(lcHTML, lcFile)
endif
	endif lcFile <> 's4g000.html'
next lnI

* Generate the index.

lcIndex = filetostr('HTMLHelp\hackfox.hhk')
lcChar  = ''
text to lcMarkdown noshow
# Welcome to HackFox!

## Introduction

endtext
lcMarkdown = lcMarkdown + ccCRLF + substr(filetostr('Section4.md'), 4) + ccCRLF
for lnI = 1 to occurs('<OBJECT', lcIndex)
	lcObject   = strextract(lcIndex, '<OBJECT', '</OBJECT>', lnI)
	lcName     = strextract(lcObject, '<param name="Name" value="', '"')
	lcFile     = strextract(lcObject, '<param name="Local" value="', '"')
	lcName     = strtran(lcName, '\', '\\')
	lcFirst    = left(strtran(lcName, '_'), 1)
	do case
		case lcFirst == lcChar
		case isalpha(lcFirst) or lcFirst = '@'
			lcMarkdown = lcMarkdown + ccCRLF + '## ' + lcFirst + ccCRLF
	endcase
	lcChar     = lcFirst
	lcMarkdown = lcMarkdown + '[' + lcName + '](Section4\' + ;
		forceext(lcFile, 'md') + ')  ' + ccCRLF
next lnI
strtofile(lcMarkdown, '..\README.md')

