FILTER = 2>&1 | grep -v NOTICE

CMD = `ruby ../Config.rb`

%.sql:		TableDefinitions.rb *.rb
		ruby -I.. gen_tables.rb

all:
		echo "use make regen \| test"

regen:		drop create load_live

test:		drop create load_test

create:		create.sql
		$(CMD) <create.sql $(FILTER)

drop:		drop.sql
		$(CMD) <drop.sql $(FILTER)
		echo "vacuum;" | $(CMD)

load_live:
		$(CMD) <livedata/load.sql $(FILTER)

load_test:
		$(CMD) <testdata/load.sql $(FILTER)
