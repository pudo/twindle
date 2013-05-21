
lists:
	python lists.py SPIEGEL_Daten/Politikertreppe
	python lists.py zeitonline_pol/bundestagsabgeordnete

reports:
	datafreeze --db $(shell echo "$(DB_URL)" | sed 's/tcp:/postgresql:/g') Freezefile.yaml
