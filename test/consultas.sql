SELECT v.nombre
FROM Votante v, Candidato can, VotacionCandidato vc, SePostulaA spa
WHERE v.dni = can.dni
AND can.dni = spa.dni
AND vc.idEleccion IN (SELECT vc2.idEleccion
                      FROM VotacionEleccion ve, VotacionCandidato vc2
                      WHERE ve.idEleccion = vc2.idEleccion
                      AND fecha >= ( SELECT MAX(fecha)
                                     FROM VotacionEleccion))
AND vc.idEleccion = spa.idEleccion
AND spa.cantVotos = (SELECT MAX(spa2.cantVotos)
                     FROM SePostulaA spa2
                     WHERE spa2.idEleccion = vc.idEleccion);

----------------------------------

SELECT cen.direccion, vot.dni
FROM Vota v, Votante vot, Mesa m, Centro cen
WHERE v.idMesa = m.idMesa
AND vot.dni = v.dni
AND m.idCentro = cen.idCentro
AND v.idEleccion IN (SELECT ve.idEleccion
                     FROM VotacionEleccion ve
                     WHERE fecha >= (SELECT MAX(fecha)
                                     FROM VotacionEleccion))
AND vot.dni IN (SELECT vot1.dni
                FROM Votante vot1, Vota v1, Mesa m1
                WHERE v1.idMesa = m1.idMesa
                AND m1.idCentro = cen.idCentro
                AND vot1.dni = v1.dni
                ORDER BY hora DESC
                LIMIT 5)
ORDER BY direccion,hora DESC;

-----------------------------------

--SELECT pp.nombre
SELECT spa.cantVotos
FROM PartidoPolitico pp, SePostulaA spa, Candidato can, Cargo c, VotacionCandidato vc
WHERE pp.idPartido = spa.idPartido
AND can.dni = spa.dni
AND spa.idEleccion = vc.idEleccion
AND vc.idEleccion IN (SELECT ve.idEleccion
                      FROM VotacionCandidato vc2, VotacionEleccion ve, Cargo c2
                      WHERE vc2.idEleccion = ve.idEleccion
                      AND c2.idCargo = vc2.idCargo
                      AND c2.nombre LIKE 'Gobernador'
                      ORDER BY ve.fecha DESC
                      LIMIT 5)
AND vc.idCargo = c.idCargo
AND c.nombre LIKE 'Gobernador'
AND spa.cantVotos > (SELECT SUM(spa2.cantVotos)*0.2
                     FROM SePostulaA spa2
                     WHERE spa2.idEleccion = vc.idEleccion);