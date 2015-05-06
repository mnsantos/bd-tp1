import os
import sqlite3

os.system('rm ../test/test.db')
os.system('sqlite3 ../test/test.db < crear_base.sql')

conn = sqlite3.connect('../test/test.db')

tables = ['Cargo', 'Territorio', 'Votante', 'VotacionEleccion', 'VotacionCandidato', 'Camioneta', 'Centro', 'Mesa', 
	'PartidoPolitico', 'EsFiscal', 'EsCandidato', 'CargoParaTerritorio', 'Afilia', 'Vota', 'Contiene']


conn.execute('PRAGMA foreign_keys = ON')
for table in tables:
	csv = open('../test/csvs/%s.csv' % (table))
	for line in csv:
		
		values = line.split(",")
		for i in range(len(values)):
			v = values[i]			
			v = v.lstrip()
			v = v.rstrip()						
			if not (v.upper() == "NULL") and not v[0].isdigit() and v[0] != '"' and v[0] != "'":
				values[i] = '"' + v + '"'
		
		line = ','.join(values)				
		#print 'INSERT INTO %s VALUES (%s)' % (table, line)
		conn.execute('INSERT INTO %s VALUES (%s)' % (table, line))
conn.close()