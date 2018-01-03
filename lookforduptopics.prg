clear
close tables
use NewAllCAndF order Topic
lcTopic = '%'
scan
	if upper(TOPIC) = lcTopic + ' ' and NGROUP <> lnGroup
		browse
	endif upper(TOPIC) = lcTopic + ' ' ...
	lcTopic = upper(trim(TOPIC))
	lnGroup = NGROUP
endscan
