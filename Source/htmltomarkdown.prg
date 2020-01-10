#define ccCR	chr(13)
#define ccLF	chr(10)
#define ccCRLF	chr(13) + chr(10)

lparameters tcHTML, ;
	tcFile
local lcHTML, ;
	lnI, ;
	lcTable, ;
	lcReplacement, ;
	lcLinks, ;
	lnLink, ;
	lcTag, ;
	lcOpen, ;
	lcHRef, ;
	lcText
lcHTML = tcHTML

* Get the body, omitting the errata and copyright notices at the end.

lcHTML = strextract(lcHTML, '<body>', '<a href="http://www.hentzenwerke.com/catalogavailability', ;
	1, 1)

* Strip errant <PRE>.

lcHTML = strtran(lcHTML, '<pre>&nbsp;</pre>', '', -1, -1, 1)

* Fix some MS styles.

lcHTML = strtran(lcHTML, "style='mso-bidi-font-style:normal'")
lcHTML = strtran(lcHTML, ' class=MsoNormal')

* Fix some bad <I> tags.

lcHTML = strtran(lcHTML, '<I' + ccCRLF, '<I', -1, -1, 1)
lcHTML = strtran(lcHTML, '<I ', '<I', -1, -1, 1)
lcHTML = strtran(lcHTML, '<I> ', ' <I>', -1, -1, 1)
lcHTML = strtran(lcHTML, ' </I>', '</I> ', -1, -1, 1)

* Replace <PRE> sections with placeholders so we don't convert certain tags in
* them to Markdown.

lnPre = occurs('<pre>', lower(lcHTML))
if lnPre > 0
	dimension laPre[lnPre]
	for lnI = lnPre to 1 step -1
		lcPre      = strextract(lcHTML, '<pre>', '</pre>', lnI, 1 + 4)
		laPre[lnI] = lcPre
		lcHTML     = strtran(lcHTML, lcPre, '%p' + transform(lnI) + '%')
	next lnI
endif lnPre > 0

* Remove CRLF in paragraphs.

for lnI = occurs('<p', lower(lcHTML)) to 1 step -1
	lcText    = strextract(lcHTML, '<p', '</p>', lnI, 1 + 4)
	lnLines   = alines(laLines, lcText)
	lcNewText = ''
	for lnJ = 1 to lnLines
		lcNewText = lcNewText + iif(lnJ > 1, ' ', '') + alltrim(laLines[lnJ])
	next lnJ
	lcHTML    = strtran(lcHTML, lcText, lcNewText)
next lnI

* Replace tables with placeholders so we don't convert tags in them to
* Markdown.

lnTables = occurs('<table ', lower(lcHTML))
if lnTables > 0
	dimension laTables[lnTables]
	for lnI = lnTables to 1 step -1
		lcTable       = strextract(lcHTML, '<table ', '</table>', lnI, 1 + 4)
		laTables[lnI] = lcTable
		lcHTML        = strtran(lcHTML, lcTable, '%t' + transform(lnI) + '%')
	next lnI
endif lnTables > 0

* Replace blockquotes with placeholders so we don't strip <BR> in them.

lnBlocks = occurs('<p class=blockquote', lower(lcHTML))
if lnBlocks > 0
	dimension laBlocks[lnBlocks]
	for lnI = lnBlocks to 1 step -1
		lcBlock       = strextract(lcHTML, '<p class=blockquote', '</p>', ;
			lnI, 1 + 4)
		laBlocks[lnI] = lcBlock
		lcHTML        = strtran(lcHTML, lcBlock, '%b' + transform(lnI) + '%')
	next lnI
endif lnBlocks > 0

* Strip <P> and <BR>.

lcHTML = strtran(lcHTML, '<p>', '', -1, -1, 1)
lcHTML = strtran(lcHTML, '</p>', ccCRLF, -1, -1, 1)
lcHTML = strtran(lcHTML, ccCRLF + '<br>' + ccCRLF, ccCRLF, -1, -1, 1)
lcHTML = strtran(lcHTML, '<br>', '  ', -1, -1, 1)

* Put the blockquotes back.

for lnI = 1 to lnBlocks
	lcBlock       = laBlocks[lnI]
	lcBlock       = strtran(lcBlock, '<br>', '<br>' + ccCRLF, -1, -1, 1)
	lcBlock       = strtran(lcBlock, '</p>', ccCRLF, -1, -1, 1)
	lcPlaceholder = '%b' + transform(lnI) + '%'
	lcHTML        = strtran(lcHTML, lcPlaceholder, lcBlock)
next lnI

* Convert headings. We have some empty <H6> tags so this'll take care of that.

lcHTML = ConvertTag(lcHTML, 'H2', '## ')
lcHTML = ConvertTag(lcHTML, 'H3', '### ')
lcHTML = ConvertTag(lcHTML, 'H4', '#### ')
lcHTML = ConvertTag(lcHTML, 'H5', '##### ')
lcHTML = ConvertTag(lcHTML, 'H6', '')

* Convert links.

lcHTML = ConvertLinks(lcHTML)

* Handle blockquotes, bullets, italics, and quotes.

lcHTML = ConvertTag(lcHTML, 'I', '*', '*')
lcHTML = ConvertTag(lcHTML, 'BLOCKQUOTE', '>')
lcHTML = ConvertTag(lcHTML, 'UL', '')
lcHTML = ConvertTag(lcHTML, 'LI', '*')
lcHTML = strtran(lcHTML, '&quot;', '"')

* Handle special Markdown characters (these have to be done after &quot;).

lcHTML = strtran(lcHTML, '"\"',  '"\\"')
lcHTML = strtran(lcHTML, '|',    '\|')
lcHTML = strtran(lcHTML, '"*"',  '"\*"')
lcHTML = strtran(lcHTML, '"_"',  '"\_"')
lcHTML = strtran(lcHTML, '"=="', '"\=="')
lcHTML = strtran(lcHTML, '{',    '\{')

* Tag keywords. Note we only handle functions and keywords with two or more
* words because lots of keywords like REPLACE and USE may be used as English
* words rather than keywords.

select NEWALLCANDF
scan for '(' $ TOPIC or ' ' $ trim(TOPIC)
	lcKeyword = trim(TOPIC)
	for lnI = 1 to occurs(upper(lcKeyword), upper(lcHTML))
		lnPos   = atc(lcKeyword, lcHTML, lnI)
		lcChar1 = substr(lcHTML, lnPos - 1, 1)
		lcChar2 = substr(lcHTML, lnPos + len(lcKeyword), 1)
		if not isalpha(lcChar1) and not isalpha(lcChar2)
			lcHTML = strtran(lcHTML, lcChar1 + lcKeyword + lcChar2, ;
				lcChar1 + '`' + lcKeyword + '`' + lcChar2, 1, 1, 1)
		endif not isalpha(lcChar1) ...
	next lnI
endscan for '(' $ TOPIC ...

* Handle images.

for lnI = 1 to occurs('<img', lower(lcHTML))
	lcImage = strextract(lcHTML, '<img', '>', 1, 1 + 4)
	lcSrc   = strextract(lcImage, 'src="', '"')
	lcHTML  = strtran(lcHTML, lcImage, '![](' + lcSrc + ')')
next lnI

* Put the <PRE> sections back.

for lnI = 1 to lnPre
	lcPre         = laPre[lnI]
	lcPlaceholder = '%p' + transform(lnI) + '%'
	lcHTML        = strtran(lcHTML, lcPlaceholder, lcPre)
	for lnJ = 1 to lnTables
		laTables[lnJ] = strtran(laTables[lnJ], lcPlaceholder, lcPre)
	next lnJ
next lnI

* Convert <PRE> to code, including unencoding.

lcHTML = ConvertPreToCode(lcHTML)

* Put the tables back, handling certain ones while we do so. We'll leave
* other tables alone because it's easier and they look better.

for lnI = 1 to lnTables
	lcTable       = laTables[lnI]
	lcPlaceholder = '%t' + transform(lnI) + '%'
	do case

* Handle the Usage table.

		case 'H3>Usage' $ lcTable
			text to lcReplacement noshow textmerge pretext 1 + 2
			### Usage
			
			<<ConvertPreToCode(strextract(lcTable, '<pre>', '</pre>', 1, 1 + 4))>>
			
			endtext
			lcHTML = strtran(lcHTML, lcPlaceholder, lcReplacement, -1, -1, 1)

* Handle the Example table.

		case 'H3>Example' $ lcTable
			text to lcReplacement noshow textmerge pretext 1 + 2
			### Example
			
			<<ConvertPreToCode(strextract(lcTable, '<pre>', '</pre>', 1, 1 + 4))>>
			
			endtext
			lcHTML = strtran(lcHTML, lcPlaceholder, lcReplacement, -1, -1, 1)

* Handle the See Also table.

		case 'H3>See Also' $ lcTable
			lcLinks = ''
			for lnLink = 1 to occurs('<A ', lcTable)
				lcTag   = strextract(lcTable, '<A ', '</A>', lnLink, 4)
				lcOpen  = left(lcTag, at('>', lcTag))
				lcHRef  = forceext(strextract(lcTag, 'HREF="', '"'), 'md')
				lcText  = strextract(lcTag, lcOpen, '</A>')
				lcLinks = lcLinks + iif(empty(lcLinks), '', ', ') + ;
					'[' + lcText + '](' + lcHRef + ')'
			next lnLink
			text to lcReplacement noshow textmerge pretext 1 + 2
			### See Also
			
			<<lcLinks>>
			endtext
			lcHTML = strtran(lcHTML, lcPlaceholder, lcReplacement)

* Put all other tables back but fix bad attributes.

		otherwise
			lcTag   = strextract(lcTable, '<table ', '>', 1, 1 + 4)
			lcTable = strtran(lcTable, lcTag, '<table>', -1, -1, 1)
			lcTable = FixAttributes(lcTable, 'td')
			lcTable = FixAttributes(lcTable, 'img')
			lcTable = FixAttributes(lcTable, 'p')
			lcTable = RemoveTrailingPAfterImage(lcTable)
			lcHTML  = strtran(lcHTML, lcPlaceholder, lcTable)
	endcase
next lnI

* Ensure there's a blank line after tables.

for lnI = 1 to occurs('</table>', lower(lcHTML))
	lnPos = atc('</table>', lcHTML, lnI)
	if substr(lcHTML, lnPos + 10, 1) <> ccCR
		lcHTML = stuff(lcHTML, lnPos + 10, 0, ccCRLF)
	endif substr(lcHTML, lnPos + 10, 1) <> ccCR
next lnI

* Replace ellipses and other symbols and errant tags.

lcHTML = strtran(lcHTML, '…', '...')
lcHTML = strtran(lcHTML, '±', '&plusmn;')
lcHTML = strtran(lcHTML, 'Ö', '&radic;')
lcHTML = strtran(lcHTML, '<I' + ccCRLF, '<I', -1, -1, 1)
lcHTML = strtran(lcHTML, '<I ', '<I', -1, -1, 1)
lcHTML = strtran(lcHTML, '<b></b>', '', -1, -1, 1)
lcHTML = strtran(lcHTML, '<b> </b>', '', -1, -1, 1)
lcHTML = strtran(lcHTML, '<b>_</b>', '_', -1, -1, 1)

* Fix specific things.

lcHTML = strtran(lcHTML, '"*X*"', '"\*X\*"', -1, -1, 1)
lcHTML = strtran(lcHTML, '®')
lcHTML = strtran(lcHTML, '¯')

* Correct the case of images.

lcHTML = strtran(lcHTML, 'design.gif',  'design.gif',  -1, -1, 1)
lcHTML = strtran(lcHTML, 'cool.gif',    'cool.gif',    -1, -1, 1)
lcHTML = strtran(lcHTML, 'bug.gif',     'bug.gif',     -1, -1, 1)
lcHTML = strtran(lcHTML, 'fixbug1.gif', 'fixbug1.gif', -1, -1, 1)

* Strip out consecutive blank lines, leading and trailing blank lines, and
* leading spaces before headings.

lcHTML = strtran(lcHTML, ccCRLF + ccCRLF + ccCRLF, ccCRLF)
lcHTML = alltrim(lcHTML, 1, ccCRLF)
lcHTML = strtran(lcHTML, ccCRLF + ' ##', ccCRLF + '##')

* Convert to UTF-8.

lcHTML = strconv(lcHTML, 9)

* Return the results.

return lcHTML

*==============================================================================
function ConvertTag(tcHTML, tcHTMLTag, tcMarkdownTag, tcClosingMarkdownTag)
*==============================================================================
local lcHTML, ;
	lcClosingTag

* Strip empty tags.

lcHTML = strtran(tcHTML, '<' + tcHTMLTag + '></' + tcHTMLTag + '>', '', -1, ;
	-1, 1)

lcClosingTag = evl(tcClosingMarkdownTag, '')

* Convert the tag.

lcHTML = strtran(lcHTML, '<' + tcHTMLTag + '>', tcMarkdownTag, -1, -1, 1)
lcHTML = strtran(lcHTML, '</' + tcHTMLTag + '>', lcClosingTag, -1, -1, 1)
lcHTML = strtran(lcHTML, '<p class=' + tcHTMLTag + '>', tcMarkdownTag, ;
	-1, -1, 1)
return lcHTML

*==============================================================================
function ConvertLinks(tcHTML)
*==============================================================================
local lcHTML, ;
	lnI, ;
	lcTag, ;
	lcOpen, ;
	lcHRef, ;
	lcText
lcHTML = tcHTML
for lnI = 1 to occurs('<A ', lcHTML)
	lcTag  = strextract(lcHTML, '<A ', '</A>', 1, 4)
	lcOpen = left(lcTag, at('>', lcTag))
	lcHRef = strextract(lcTag, 'HREF = "', '"')
	lcText = strextract(lcTag, lcOpen, '</A>')
	lcHTML = strtran(lcHTML, lcTag, '[' + lcText + '](' + lcHRef + ')')
next lnI
return lcHTML

* Convert <PRE> to code, including unencoding.

*==============================================================================
function ConvertPreToCode(tcHTML)
*==============================================================================
local lcHTML, ;
	lnI, ;
	lcCode, ;
	lcNewCode
lcHTML = tcHTML
for lnI = 1 to occurs('<pre>', lower(lcHTML))
	lcCode    = strextract(lcHTML, '<pre>', '</pre>', lnI, 1 + 4)
	lcNewCode = strtran(lcCode,    '&lt;',   '<')
	lcNewCode = strtran(lcNewCode, '&gt;',   '>')
	lcNewCode = strtran(lcNewCode, '&quot;', '"')
	lcNewCode = strtran(lcNewCode, '&nbsp;', ' ')
	lcNewCode = strtran(lcNewCode, '&amp;',  '&')
	lcHTML    = strtran(lcHTML, lcCode, lcNewCode)
next lnI
lcHTML = strtran(lcHTML, '<pre>',  '```foxpro' + ccCRLF, -1, -1, 1)
lcHTML = strtran(lcHTML, '</pre>', ccCRLF + '```', -1, -1, 1)
return lcHTML

*==============================================================================
function FixAttributes(tcHTML, tcTag)
*==============================================================================

* Adds missing quotes around attributes values e.g. width=83 becomes width="83"

local lcHTML, ;
	lcFindTag, ;
	lnTag, ;
	lcTag, ;
	lcNewTag, ;
	lnAttr, ;
	lcAttr
lcHTML    = tcHTML
lcFindTag = '<' + tcTag + ' '
for lnTag = 1 to occurs(lcFindTag, lcHTML)
	lcTag    = strextract(lcHTML, lcFindTag, '>', lnTag, 1 + 4)
	lcNewTag = lcTag
	for lnAttr = 1 to occurs('=', lcTag)
		lcAttr = strextract(lcTag, '=', ' ', lnAttr)
		if empty(lcAttr)
			lcAttr = strextract(lcTag, '=', '>', lnAttr)
		endif empty(lcAttr)
		if left(lcAttr, 1) <> '"'
			lcNewTag = strtran(lcNewTag, '=' + lcAttr, '="' + lcAttr + '"')
		endif left(lcAttr, 1) <> '"'
	next lnAttr
	lcHTML = strtran(lcHTML, lcTag, lcNewTag, -1, -1, 1)
next lnTag
return lcHTML

*==============================================================================
function RemoveTrailingPAfterImage(tcHTML)
*==============================================================================

local lcHTML, ;
	lnI, ;
	lcTag
lcHTML = tcHTML
for lnI = 1 to occurs('<img', lcHTML)
	lcTag  = strextract(lcHTML, '<img', '>', lnI, 1 + 4)
	lcHTML = strtran(lcHTML, lcTag + '</p>', lcTag, -1, -1, 1)
next lnI
for lnI = 1 to occurs('<img', lcHTML)
	lcTag  = strextract(lcHTML, '<img', '>', lnI, 1 + 4)
	lcHTML = strtran(lcHTML, '<p>' + lcTag, lcTag, -1, -1, 1)
next lnI
return lcHTML
