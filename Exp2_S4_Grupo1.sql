SHOW USER;

-- ACTIVIDAD FORMATICA
/*lILIAN ZAPATA
IGNACIO TORO
CONSULTA BASE DE DATOS
*/

-- DESAFIO 1

SELECT 
    UPPER(t.nombre || ' ' || t.appaterno || ' ' || t.apmaterno) AS "Nombre Completo",
    TO_CHAR(t.numrut, '999G999G999') || '-' || t.dvrut AS "RUT",  -- RUT con puntos
    tt.desc_categoria AS "Tipo Trabajador",
    UPPER(c.nombre_CIUDAD) AS "Ciudad",  -- Convertir la ciudad a mayúsculas
    TO_CHAR(t.sueldo_base, '$999G999G999') AS "Sueldo Base"  -- Sueldo con signo $ al principio
FROM 
    trabajador t
JOIN 
    tipo_trabajador tt ON t.id_categoria_t = tt.id_categoria
JOIN 
    comuna_ciudad c ON t.id_ciudad = c.id_CIUDAD
WHERE 
    t.sueldo_base BETWEEN 650000 AND 3000000
ORDER BY 
    c.nombre_CIUDAD DESC, t.sueldo_base ASC;

-- DESAFIO 2


SELECT
    TO_CHAR(t.numrut, '999G999G999') || '-' || t.dvrut AS "RUT",  -- RUT con puntos
    INITCAP(LOWER(t.nombre)) || ' ' || UPPER(t.appaterno) AS "Nombre",  -- Nombre con la primera letra en mayúscula y el resto en minúscula
    COUNT(tc.nro_ticket) AS "CANTIDAD",
    TO_CHAR(SUM(tc.monto_ticket), '$999G999G999') AS "Total Vendido",  -- Total con signo $ al principio y sin espacio
    TO_CHAR(SUM(ct.valor_comision), '$999G999G999') AS "Comisión Total",  -- Comisión con signo $ al principio y sin espacio
    tt.desc_categoria AS "Tipo Trabajador",
    UPPER(c.nombre_CIUDAD) AS "Ciudad"  -- Ciudad en mayúsculas
FROM 
    trabajador t
JOIN 
    tipo_trabajador tt ON t.id_categoria_t = tt.id_categoria
JOIN 
    comuna_ciudad c ON t.id_ciudad = c.id_CIUDAD
JOIN 
    tickets_concierto tc ON t.numrut = tc.numrut_t
JOIN 
    comisiones_ticket ct ON tc.nro_ticket = ct.nro_ticket
WHERE 
    tt.desc_categoria = 'CAJERO'
GROUP BY
    t.numrut, t.dvrut, t.nombre, t.appaterno, t.apmaterno, tt.desc_categoria, c.nombre_CIUDAD
HAVING 
    SUM(tc.monto_ticket) > 50000
ORDER BY 
    "Total Vendido" DESC;

-- desafio 3

SELECT 
    t.numrut AS "RUT",  -- RUT sin puntos, guion ni digito verificador
    UPPER(t.nombre || ' ' || t.appaterno) AS "NOMBRE",  -- Nombre completo en mayúscula
    TO_CHAR(t.fecing, 'YYYY') AS "ANIO_INGRESO",  -- Renombrado a ANIO_INGRESO
    EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing) AS "ANTIGUEDAD",
    NVL((
        SELECT COUNT(*) 
        FROM ASIGNACION_FAMILIAR af 
        WHERE af.numrut_t = t.numrut
    ), 0) AS "CARGAS_FAMILIARES",
    UPPER(INITCAP(i.nombre_isapre)) AS "TIPO_ISAPRE",  -- TIPO_ISAPRE en mayúsculas
    TO_CHAR(t.sueldo_base, '$999G999G999', 'NLS_NUMERIC_CHARACTERS=''.,''') AS "SUELDO",  -- Signo $ pegado al principio
    TO_CHAR(
        CASE 
            WHEN i.nombre_isapre = 'FONASA' THEN ROUND(t.sueldo_base * 0.01)
            ELSE 0 
        END, 
        '$999G999G999', 'NLS_NUMERIC_CHARACTERS=''.,'''  -- Signo $ pegado al principio
    ) AS "BONO_ISAPRE",
    TO_CHAR(
        CASE 
            WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing)) <= 10 
                THEN ROUND(t.sueldo_base * 0.10)
            ELSE 
                ROUND(t.sueldo_base * 0.15)
        END, 
        '$999G999G999', 'NLS_NUMERIC_CHARACTERS=''.,'''  -- Signo $ pegado al principio
    ) AS "BONO_ANTIGUEDAD",  -- Signo $ pegado al principio
    a.nombre_afp AS "AFP",
    INITCAP(ec.desc_estcivil) AS "ESTADO_CIVIL_ACTUAL"
FROM 
    TRABAJADOR t
    JOIN ISAPRE i ON t.cod_isapre = i.cod_isapre
    JOIN AFP a ON t.cod_afp = a.cod_afp
    JOIN EST_CIVIL est ON t.numrut = est.numrut_t
    JOIN ESTADO_CIVIL ec ON est.id_estcivil_est = ec.id_estcivil
WHERE 
    est.fecter_estcivil IS NULL
ORDER BY 
    t.numrut;