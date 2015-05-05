SELECT vot.nombre
FROM Votante vot, VotacionCandidato vc, EsCandidato escan
WHERE vot.dni = escan.dni
AND vc.idEleccion IN (SELECT idEleccion
                      FROM VotacionCandidato
                      WHERE fechaInicio >= ( SELECT MAX(fechaInicio)
                                             FROM VotacionCandidato))
AND vc.idEleccion = escan.idEleccion
AND escan.cantVotos = (SELECT MAX(escan2.cantVotos)
                       FROM EsCandidato escan2
                       WHERE escan2.idEleccion = vc.idEleccion);

----------------------------------

SELECT cen.direccion, vot.dni
FROM Vota v, Votante vot, Mesa m, Centro cen
WHERE v.idMesa = m.idMesa
AND vot.dni = v.dni
AND m.idCentro = cen.idCentro
AND vot.dni IN (SELECT vot1.dni
                FROM Votante vot1, Vota v1, Mesa m1
                WHERE v1.idMesa = m1.idMesa
                AND m1.idCentro = cen.idCentro
                AND vot1.dni = v1.dni
                ORDER BY hora DESC
                LIMIT 5)
ORDER BY direccion,hora DESC;

-----------------------------------

SELECT pp.nombre
FROM PartidoPolitico pp, Afilia A, Votante vot, EsCandidato ec, CargoParaTerritorio ct, Cargo cantVotos
WHERE pp.idPartido = A.idPartido
AND vot.dni = A.dni
AND vot.dni = ec.dni
AND ec.idEleccion = 0 --HARDCODE
AND ct.idCargo = C.idCargo
AND C.nombre LIKE 'Gobernador'
AND ec.cantVotos > (SELECT SUM(cantVotos)*0.2
                FROM EsCandidato
                WHERE idEleccion = ec.idEleccion);idEleccion