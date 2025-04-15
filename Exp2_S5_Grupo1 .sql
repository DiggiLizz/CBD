/* FORMATIVA SEMANA 5
LILIAN ZAPATA
IGNACIO TORO
GRUPO 1
*/

show user;

-- DESAFIO 1

SELECT 
    cli.numrun || '-' || cli.dvrun AS "RUT_CLIENTE",  -- concatenacion rut y dv
    INITCAP(cli.pnombre || ' ' || cli.appaterno) AS "NOMBRE_CLIENTE",  -- concatenacion nombre letra capital
    prof.nombre_prof_ofic AS "PROFESION",
    TO_CHAR(cli.fecha_inscripcion, 'DD-MM-YYYY') AS "FECHA_INSCRIP", -- cambio formato de la fecha
    cli.direccion AS "DIRECCION"
FROM 
    cliente cli
JOIN 
    profesion_oficio prof ON cli.cod_prof_ofic = prof.cod_prof_ofic -- union de profesio con el coido de profesion
JOIN 
    tipo_cliente tcli ON cli.cod_tipo_cliente = tcli.cod_tipo_cliente  -- union de cliente con codigo de tipo de cliente
WHERE 
    UPPER(prof.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')  -- profesiones buscadas
    AND UPPER(tcli.nombre_tipo_cliente) = 'TRABAJADORES DEPENDIENTES'  -- solo clietes independientes
    AND EXTRACT(YEAR FROM cli.fecha_inscripcion) > (  -- select secundario para sacar  el promedio de los a os
        SELECT                                        -- para redondear, y elegir que el a o sea mayor al promedio
            ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion))) FROM cliente
    )
ORDER BY 
    cli.numrun ASC; -- ordenar ascendente por numero de run


-- DESAFIO 2
SELECT 
    cli.numrun || '-' || cli.dvrun AS "RUT_CLIENTE", -- concatenacion run y dv
    ROUND(MONTHS_BETWEEN(SYSDATE, cli.fecha_nacimiento) / 12) AS "EDAD", -- redondear edad entre la fecha actual y fech nac
    TO_CHAR(t.cupo_disp_compra, '$999G999G999') AS "CUPO_DISPONIBLE_COMPRA", --formateo del cupo a pesos
    UPPER(tcli.nombre_tipo_cliente) AS "TIPO_CLIENTE"
FROM 
    cliente cli
JOIN 
    tarjeta_cliente t ON cli.numrun = t.numrun -- union de tajeta con num run de cliente
JOIN 
    tipo_cliente tcli ON cli.cod_tipo_cliente = tcli.cod_tipo_cliente  -- union tipo cliente con cod del tipo de cliente
WHERE 
    t.cupo_disp_compra >= (
        SELECT MAX(t2.cupo_disp_compra) -- select de consukta para sacar el max de cupo del a o anterior
            FROM tarjeta_cliente t2
            WHERE EXTRACT(YEAR FROM t2.fecha_solic_tarjeta) = EXTRACT(YEAR FROM SYSDATE) - 1
    )
ORDER BY 
    ROUND(MONTHS_BETWEEN(SYSDATE, cli.fecha_nacimiento) / 12) ASC; -- ordenar por edad ascendente
    

-- creacion de la tabla para almacenar la informacion de la consulta
CREATE TABLE CUPO_DISPONIBLE_COMPRA ( 
    numrun             VARCHAR2(10) NOT NULL, 
    dvrun              VARCHAR2(1) NOT NULL,
    fecha_nacimiento   DATE NOT NULL,
    cupo_disp_compra   VARCHAR2(20) NOT NULL, 
    tipo_cliente       VARCHAR2(40) NOT NULL
);
-- ALTER PARA VER QUE NO SE REPITA CLIENTE
ALTER TABLE CUPO_DISPONIBLE_COMPRA ADD CONSTRAINT PK_CUPO_COMPRA PRIMARY KEY (numrun, dvrun);