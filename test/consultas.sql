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
                       WHERE escan2.idEleccion = vc.idEleccion)

----------------------------------

SELECT cen.direccion, vot.dni
FROM VOTA V, Votante C, Mesa M, Centro cen
WHERE V.idMesa = M.idMesa
AND M.idCentro = cen.idCentro
AND vot.dni IN (SELECT vot1.dni
                FROM Votante vot1, VOTA V1, Mesa M1, Centro vot1
                WHERE V1.IDMesa = M1.IDMesa
                AND M1.idCentro = cen.idCentro
                ORDER BY HORA DESC
                LIMIT 5)

-----------------------------------

SELECT PP.nombre
FROM PARTIDO_POLITICO PP AFILIA A, Votante vot, EsCandidato EC, SEVOTAPOR VP, CARGO cantVotos
WHERE PP.IDPARTIDO = A.IDPARTIDO
AND vot.dni = A.dni
AND vot.dni = EC.dni
AND EC.IDELECCION (..FALTA! ULTIMAS 5 ELECCIONES)
AND VP.IDCARGO = C.IDCARGO
AND C.nombre = 'GOBERNADOR'
AND EC.VOTOS > (SELECT SUM(VOTOS)/5
                FROM EsCandidato
                WHERE IDELECCION = EC.IDELECCION)