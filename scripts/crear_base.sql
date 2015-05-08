CREATE TABLE Cargo(
	idCargo INTEGER PRIMARY KEY, 
	nombre VARCHAR2, 
	fechaInicio INTEGER, 
	fechaFin INTEGER
);

CREATE TABLE Territorio(
	idTerritorio INTEGER PRIMARY KEY, 
	nombre VARCHAR2, 
	idSupraTerritorio INTEGER, 
	FOREIGN KEY(idSupraTerritorio) REFERENCES Territorio(idTerritorio)
);

CREATE TABLE Votante(
	DNI INTEGER PRIMARY KEY, 
	nombre VARCHAR2, 
	idTerritorio INTEGER, 
	FOREIGN KEY(idTerritorio) REFERENCES Territorio(idTerritorio)
);

CREATE TABLE Candidato(
	DNI INTEGER PRIMARY KEY,
	FOREIGN KEY(DNI) REFERENCES Votante(DNI)
);

CREATE TABLE Camioneta(
	Patente VARCHAR2 PRIMARY KEY, 
	DNI INTEGER, 
	FOREIGN KEY(DNI) REFERENCES Votante(DNI)
);

CREATE TABLE Centro(
	idCentro INTEGER PRIMARY KEY, 
	direccion VARCHAR2, 
	patente VARCHAR2, 
	idTerritorio INTEGER, 
	FOREIGN KEY(patente) REFERENCES Camioneta(patente), 
	FOREIGN KEY(idTerritorio) REFERENCES Territorio(idTerritorio)
);

CREATE TABLE Mesa(
	idMesa INTEGER PRIMARY KEY, 
	idCentro INTEGER, 
	FOREIGN KEY(idCentro) REFERENCES Centro(idCentro)
);

CREATE TABLE VotacionPorMesa(
	idEleccion INTEGER, 
	idMesa INTEGER, 
	DNI_Presidente INTEGER, 
	DNI_Vice INTEGER, 
	DNI_Tecnico INTEGER, 
	PRIMARY KEY(idEleccion,idMesa), 
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion), 
	FOREIGN KEY(idMesa) REFERENCES Mesa(idMesa), 
	FOREIGN KEY(DNI_Presidente) REFERENCES Votante(DNI), 
	FOREIGN KEY(DNI_Vice) REFERENCES Votante(DNI), 
	FOREIGN KEY(DNI_Tecnico) REFERENCES Votante(DNI)
);

CREATE TABLE EsFiscal(
	DNI INTEGER, 
	idEleccion INTEGER, 
	idMesa INTEGER, 
	idPartido INTEGER, 
	PRIMARY KEY(DNI,idEleccion,idMesa), 
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion), 
	FOREIGN KEY(idMesa) REFERENCES Mesa(idMesa), 
	FOREIGN KEY(DNI) REFERENCES Votante(DNI), 
	FOREIGN KEY(idPartido) REFERENCES PartidoPolitico(idPartido)
);

CREATE TABLE VotacionEleccion(
	idEleccion INTEGER PRIMARY KEY, 
	tipo INTEGER,
	fecha INTEGER
);

CREATE TABLE VotacionCandidato(
	idEleccion INTEGER PRIMARY KEY, 
	idCargo INTEGER, 
	idTerritorio INTEGER, 
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion), 
	FOREIGN KEY(idCargo) REFERENCES Cargo(idCargo), 
	FOREIGN KEY(idTerritorio) REFERENCES Territorio(idTerritorio)
);

CREATE TABLE VotacionConsultaPopular(
	idEleccion INTEGER PRIMARY KEY,
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion)
);

CREATE TABLE Vota(
	DNI INTEGER, 
	idEleccion INTEGER, 
	idMesa INTEGER, 
	hora INTEGER, 
	PRIMARY KEY(DNI,idEleccion,idMesa), 
	FOREIGN KEY(DNI) REFERENCES Votante(DNI), 
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion), 
	FOREIGN KEY(idMesa) REFERENCES Mesa(idMesa)
);

CREATE TABLE PartidoPolitico(
	idPartido INTEGER PRIMARY KEY, 
	nombre VARCHAR2
);

CREATE TABLE ConsultaPopular(
	idConsulta INTEGER PRIMARY KEY,
	idEleccion INTEGER,
	descripcion VARCHAR2,
	FOREIGN KEY(idEleccion) REFERENCES VotacionConsultaPopular(idEleccion)
);

CREATE TABLE Voto(
	idVoto INTEGER PRIMARY KEY ASC,
	idEleccion INTEGER,
	idMesa INTEGER,
	tipo INTEGER,
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion),
	FOREIGN KEY(idMesa) REFERENCES Mesa(idMesa)
);

CREATE TABLE VotoCandidato(
	idVoto INTEGER PRIMARY KEY,
	DNI INTEGER,
	FOREIGN KEY(idVoto) REFERENCES Voto(idVoto),
	FOREIGN KEY(DNI) REFERENCES Candidato(DNI)
);

CREATE TABLE VotoConsultaPopular(
	idVoto INTEGER PRIMARY KEY,
	idConsulta INTEGER,
	FOREIGN KEY(idVoto) REFERENCES Voto(idVoto),
	FOREIGN KEY(idConsulta) REFERENCES ConsultaPopular(idConsulta)
);

CREATE TABLE ViveEn(
	DNI INTEGER,
	idTerritorio INTEGER,
	fechaInicio INTEGER,
	fechaFin INTEGER,
	PRIMARY KEY(DNI, idTerritorio, fechaInicio),
	FOREIGN KEY(DNI) REFERENCES Votante(DNI),
	FOREIGN KEY(idTerritorio) REFERENCES Territorio(idTerritorio)
);

CREATE TABLE RigePara(
	idCargo INTEGER,
	idTerritorio INTEGER,
	PRIMARY KEY(idCargo, idTerritorio),
	FOREIGN KEY(idCargo) REFERENCES Cargo(idCargo),
	FOREIGN KEY(idTerritorio) REFERENCES Territorio(idTerritorio)
);

CREATE TABLE SePostulaA(
	DNI INTEGER,
	idEleccion INTEGER,
	idPartido INTEGER,
	cantVotos INTEGER,
	PRIMARY KEY(DNI, idEleccion),
	FOREIGN KEY(DNI) REFERENCES Candidato(DNI),
	FOREIGN KEY(idPartido) REFERENCES PartidoPolitico(idPartido),
	FOREIGN KEY(idEleccion) REFERENCES VotacionCandidato(idEleccion)
);

CREATE TABLE VotaEn (
	DNI INTEGER, 
	idEleccion INTEGER, 
	idMesa INTEGER, 	
	PRIMARY KEY(DNI,idEleccion,idMesa), 
	FOREIGN KEY(DNI) REFERENCES Votante(DNI), 
	FOREIGN KEY(idEleccion) REFERENCES VotacionEleccion(idEleccion), 
	FOREIGN KEY(idMesa) REFERENCES Mesa(idMesa)
);

CREATE TRIGGER AsignarVotoRandomCandidato AFTER INSERT ON Vota
	WHEN New.idEleccion IN (SELECT vc.idEleccion FROM VotacionCandidato vc)
	BEGIN				
		iNSERT INTO Voto(idVoto, idEleccion, idMesa, tipo) 
			SELECT MAX(idVoto)+1, New.idEleccion, New.idMesa, 1
			FROM Voto;

		INSERT INTO VotoCandidato (idVoto, DNI) 			
			SELECT MAX(idVoto), DNI 
			FROM Voto, SePostulaA spa
			WHERE spa.idEleccion = New.idEleccion AND 
				DNI IN (SELECT DNI FROM SePostulaA ORDER BY RANDOM() LIMIT 1);
	END;

CREATE TRIGGER AsignarVotoRandomConsultaPopular AFTER INSERT ON Vota
	WHEN New.idEleccion IN (SELECT vc.idEleccion FROM VotacionConsultaPopular vc)
	BEGIN				
		iNSERT INTO Voto(idVoto, idEleccion, idMesa, tipo) 
			SELECT MAX(idVoto)+1, New.idEleccion, New.idMesa, 2 
			FROM Voto;

		INSERT INTO VotoConsultaPopular (idVoto, idConsulta) 
			SELECT MAX(idVoto), idConsulta FROM Voto, ConsultaPopular cp
			WHERE cp.idEleccion = New.idEleccion AND
				idConsulta IN (SELECT idConsulta FROM ConsultaPopular ORDER BY RANDOM() LIMIT 1);
	END;

CREATE TRIGGER SumarVotos AFTER INSERT ON VotoCandidato
	BEGIN				
		UPDATE SePostulaA SET 
			cantVotos = (SELECT COUNT(*) FROM VotoCandidato vc WHERE vc.DNI = SePostulaA.DNI)
			WHERE SePostulaA.DNI = New.DNI;			
	END;

CREATE TRIGGER FiscalNoPermitido BEFORE INSERT ON EsFiscal	
	BEGIN
		SELECT (RAISE(ABORT,"TRIGGER Error 'EsFiscal': Ya existe un fiscal del partido politico en esa mesa."))
		WHERE EXISTS (SELECT 1 FROM EsFiscal AS ef 
			WHERE New.idPartido = ef.idPartido
		);		
	END;
