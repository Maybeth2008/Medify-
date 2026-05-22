
-- PROYECTO BASE DE DATOS - MEDIFY

-- ADMIN
-- 1. MEDICAMENTOS CON STOCK BAJO O AGOTADO

SELECT 
    id_med,
    nombre_med,
    stock_med,
    stock_minimo_med,
    laboratorio_med
FROM medicamentos
WHERE stock_med <= stock_minimo_med
ORDER BY stock_med ASC;



-- 2. MEDICAMENTOS PRÓXIMOS A VENCER

SELECT 
    id_med,
    nombre_med,
    fecha_vencimiento_med,
    stock_med,
    laboratorio_med
FROM medicamentos
WHERE fecha_vencimiento_med 
      BETWEEN CURRENT_DATE 
      AND CURRENT_DATE + INTERVAL '30 days'
ORDER BY fecha_vencimiento_med ASC;


-- 3. VALOR ECONÓMICO DEL INVENTARIO

SELECT 
    nombre_med,
    stock_med,
    precio_med,
    (stock_med * precio_med) AS valor_total
FROM medicamentos
ORDER BY valor_total DESC;



-- 4. MEDICAMENTOS MÁS RECETADOS

WITH medicamentos_recetados AS (
    SELECT 
        m.nombre_med,
        COUNT(r.id_rec) AS total_recetas
    FROM recetas r
    INNER JOIN medicamentos m 
        ON r.medicamento_id = m.id_med
    GROUP BY m.nombre_med
)
SELECT *
FROM medicamentos_recetados
ORDER BY total_recetas DESC
LIMIT 10;

-- WITH (CTE) crea una tabla temporal dentro de la consulta para organizar y reutilizar resultados sin guardarlos en la base de datos.


-- DOCTOR
-- 5. HISTORIAL CLÍNICO DE UN PACIENTE (ingresar la identificación)

SELECT 
    p.nombre_paciente,
    p.apellido_paciente,
    h.diagnostico,
    h.fecha,
    d.nombre_doc
FROM historial h
INNER JOIN pacientes p 
    ON h.paciente_id = p.id_paciente
INNER JOIN doctores d 
    ON h.doctor_id = d.id_doc
WHERE p.identificacion_paciente = '12345'
ORDER BY h.fecha DESC;



-- 6. MEDICAMENTOS DISPONIBLES

SELECT 
    id_med,
    nombre_med,
    stock_med,
    fecha_vencimiento_med
FROM medicamentos
WHERE disponible_med = true
  AND stock_med > 0
  AND fecha_vencimiento_med > CURRENT_DATE
ORDER BY nombre_med;



-- 7. PACIENTES ATENDIDOS POR DOCTOR

SELECT 
    d.nombre_doc,
    COUNT(DISTINCT h.paciente_id) AS total_pacientes
FROM historial h
INNER JOIN doctores d
    ON h.doctor_id = d.id_doc
GROUP BY d.nombre_doc
ORDER BY total_pacientes DESC;


-- PACIENTE
-- 8. RECETAS MÉDICAS DEL PACIENTE (ingresar la identificación)

SELECT 
    p.nombre_paciente,
    p.apellido_paciente,
    m.nombre_med,
    r.dosis,
    r.indicaciones
FROM recetas r
INNER JOIN pacientes p
    ON r.paciente_id = p.id_paciente
INNER JOIN medicamentos m
    ON r.medicamento_id = m.id_med
WHERE p.identificacion_paciente = '12345';



-- 9. CONSULTA DE MEDICAMENTOS (en este caso acetaminofén)

SELECT 
    nombre_med,
    stock_med,
    disponible_med,
    fecha_vencimiento_med
FROM medicamentos
WHERE nombre_med ILIKE '%acetaminofen%';



-- 10. ÚLTIMA CONSULTA MÉDICA

SELECT *
FROM (
    SELECT 
        p.nombre_paciente,
        p.apellido_paciente,
        h.diagnostico,
        h.fecha,
        ROW_NUMBER() OVER(
            PARTITION BY p.id_paciente
            ORDER BY h.fecha DESC
        ) AS fila
    FROM historial h
    INNER JOIN pacientes p
        ON h.paciente_id = p.id_paciente
) t
WHERE fila = 1;

-- ROW_NUMBER() asigna un número a cada fila dentro de un grupo según un orden específico para poder identificar, por ejemplo, el registro más reciente o el primero.
