#define ccCRLF chr(13) + chr(10)

lcOutputDir = '..\..\GitHubContent\section4\'
erase log.txt

* Set this as necessary.

llIndex = .F.

* Open the keyword table.

use NEWALLCANDF

* Get all the S4G files.

lcHTMLFolder = 'HTMLForMarkdown\'
lnFiles = adir(laFiles, lcHTMLFolder + 's4g*.html')
for lnI = 1 to lnFiles
	lcFile = lower(laFiles[lnI, 1])
	if lcFile <> 's4g000.html'
*if '031' $ juststem(lcFile)
		lcHTML = filetostr(lcHTMLFolder + lcFile)
		lcHTML = HTMLToMarkdown(lcHTML, lcFile)
		lcFile = lcOutputDir + juststem(lcFile) + '.md'
		strtofile(lcHTML, lcFile)
*endif
	endif lcFile <> 's4g000.html'
next lnI

* Generate the index.

if llIndex
	lcIndex = filetostr('HTMLHelp\hackfox.hhk')
	lcChar  = ''
	lcMarkdown = filetostr('Markdown/s4cover.md') + ccCRLF
	for lnI = 1 to occurs('<OBJECT', lcIndex)
		lcObject   = strextract(lcIndex, '<OBJECT', '</OBJECT>', lnI)
		lcName     = strextract(lcObject, '<param name="Name" value="', '"')
		lcFile     = strextract(lcObject, '<param name="Local" value="', '"')
		lcName     = strtran(lcName, '\', '\\')
		lcFirst    = left(strtran(lcName, '_'), 1)
		do case
			case lcFirst == lcChar
			case isalpha(lcFirst) or lcFirst = '@'
				lcLink     = '<a name="' + iif(lcFirst = '@', 'AT', lcFirst) + ;
					'">' + lcFirst + '</a>'
				lcMarkdown = lcMarkdown + ccCRLF + '## ' + lcLink + ccCRLF
		endcase
		lcChar     = lcFirst
		lcMarkdown = lcMarkdown + '[' + lcName + '](' + forceext(lcFile, 'md') + ;
			')  ' + ccCRLF
	next lnI
	strtofile(lcMarkdown, lcOutputDir + 'index.md')
endif llIndex

if file('log.txt')
	modify file log.txt nowait
endif file('log.txt')
