# Install dionline.org in the test system

dummy:
	echo "make test   or   make live"

test:	all.tgz common
	scp all.tgz dionline@dionline.org:dion8080/site/dion/all.tgz
	ssh -l dionline dionline.org 'cd dion8080/site/dion && tar zxf all.tgz'

live:	all.tgz common
	scp all.tgz dionline@dionline.org:site/dion/all.tgz
	ssh -l dionline dionline.org 'cd site/dion && tar zxf all.tgz'



.PHONY:	all.tgz

all.tgz:
	tar czf all.tgz \
		`find . -name \*.rb -o -name words -o -name \*.sty|grep -v Config.rb` 

#	tar czf all.tgz doc/userguides/*.pdf \

common:
	scp images/whtbk.gif dionline@dionline.org:site/images/whtbk.gif
	scp *.css dionline@dionline.org:site/
