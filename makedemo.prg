* Create a demo version by overwriting all but the first topic in each
* non-S4 section and all but the first topic in each letter of the S4 section
* with a "This is a demo" HTML file.

copy file HTMLHelp\preview.html to HTMLHelp\s1c2.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c3.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c4.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c5.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c6.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c7.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c8.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c9.html
copy file HTMLHelp\preview.html to HTMLHelp\s1c10.html
copy file HTMLHelp\preview.html to HTMLHelp\s2c3.html
copy file HTMLHelp\preview.html to HTMLHelp\s2c4.html
copy file HTMLHelp\preview.html to HTMLHelp\s2c5.html
copy file HTMLHelp\preview.html to HTMLHelp\s2c6.html
copy file HTMLHelp\preview.html to HTMLHelp\s3c2.html
copy file HTMLHelp\preview.html to HTMLHelp\s3c3.html
copy file HTMLHelp\preview.html to HTMLHelp\s3c4.html

close tables all
create cursor LEAVE (NGROUP N(3))
index on NGROUP tag NGROUP
select 0
use NEWALLCANDF order FIXTOPIC
lcLetter = chr(255)
set step on 
scan
	lnGroup = NGROUP
	do case
		case seek(lnGroup, 'LEAVE')
		case left(TOPIC, 1) = lcLetter
			copy file HTMLHelp\preview.html to ;
				('HTMLHelp\s4g' + padl(lnGroup, 3, '0') + '.html')
		otherwise
			insert into LEAVE values (lnGroup)
	endcase
	lcLetter = left(TOPIC, 1)
endscan
use
use in LEAVE


copy file HTMLHelp\preview.html to HTMLHelp\s5c2.html
copy file HTMLHelp\preview.html to HTMLHelp\s5c3.html
copy file HTMLHelp\preview.html to HTMLHelp\s5c4.html
copy file HTMLHelp\preview.html to HTMLHelp\s6c2.html
copy file HTMLHelp\preview.html to HTMLHelp\s6c3.html

