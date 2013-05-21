
lists:
	python lists.py SPIEGEL_Daten/Politikertreppe
	python lists.py zeitonline_pol/bundestagsabgeordnete

reports:
	export SQLA_URL=`echo $DB_URL | sed 's/tcp:/postgresql:/g'`
	datafreeze --db $SQLA_URL Freezefile.yaml
