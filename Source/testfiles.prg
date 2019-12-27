* Create a list of actual files.

close databases all
create cursor ACTUAL (FILE C(7))
lnFiles = adir(laFiles, 'WordDocs\*.*')
for lnI = 1 to lnFiles
	if not inlist(justext(laFiles[lnI, 1]), 'FXP', 'PRG', 'ZIP', 'GIF', 'JPG')
		insert into ACTUAL values (juststem(laFiles[lnI, 1]))
	endif not inlist(justext(laFiles[lnI, 1]) ...
next lnI
index on FILE tag FILE

* Now see if any are missing.

clear
? 'Missing new files:'
select 0
use STATUS order CHAPTER
scan for not empty(WRITTENBY)
	lcFile = upper(alltrim(left(CHAPTER, 3) + iif(substr(CHAPTER, 2, 1) = '4', ;
		padl(alltrim(substr(CHAPTER, 4)), 3, '0'), substr(CHAPTER, 4))))
	if not seek(lcFile, 'ACTUAL')
		? CHAPTER, WRITTENBY
	endif not seek(lcFile, 'ACTUAL')
endscan for not empty(WRITTENBY)

* Now see if we have any we shouldn't have.

select ACTUAL
? 'Extra files:'
list for not seek(lower(FILE), 'STATUS', 'FIXEDCHAP')

* Do the same thing for original docs.

close databases all
create cursor ACTUAL (FILE C(7))
lnFiles = adir(laFiles, 'OriginalDocs\*.*')
for lnI = 1 to lnFiles
	if not inlist(justext(laFiles[lnI, 1]), 'FXP', 'PRG', 'ZIP', 'GIF', 'JPG')
		insert into ACTUAL values (juststem(laFiles[lnI, 1]))
	endif not inlist(justext(laFiles[lnI, 1]) ...
next lnI
index on FILE tag FILE

* Now see if any are missing.

? 'Missing original files:'
select 0
use STATUS order CHAPTER
scan for empty(WRITTENBY)
	lcFile = upper(alltrim(left(CHAPTER, 3) + iif(substr(CHAPTER, 2, 1) = '4', ;
		padl(alltrim(substr(CHAPTER, 4)), 3, '0'), substr(CHAPTER, 4))))
	if not seek(lcFile, 'ACTUAL')
		? CHAPTER, WRITTENBY
	endif not seek(lcFile, 'ACTUAL')
endscan for empty(WRITTENBY)


close databases all
