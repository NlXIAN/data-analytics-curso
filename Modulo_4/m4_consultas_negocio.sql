-- RetailPro | Pre-entrega 4: Consultas SQL de negocio
-- Base de datos: Ventas_Tech_DB
-- Las consultas utilizan solamente la tabla ventas.

USE Ventas_Tech_DB;
GO

-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    CAST(AVG(CAST(cantidad * precio_unitario AS DECIMAL(18, 2))) AS DECIMAL(18, 2)) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- CONSULTA 2: Ranking de los 5 productos con mayor facturacion
-- Se muestran el ID, las unidades vendidas y el importe total.
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC, id_producto ASC;

-- CONSULTA 3: Clientes recurrentes
-- Clientes que realizaron mas de un pedido y su gasto total.
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;

-- CONSULTA 4: Facturacion por producto comparada con el promedio
-- Primero se calcula el total por producto; despues, el promedio de esos totales.
WITH facturacion_por_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_por_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_por_producto
ORDER BY total_facturado DESC, id_producto ASC;

-- HALLAZGOS DEL ANALISIS
-- 1. En marzo de 2024 se registraron 10 pedidos, con una facturacion total
--    de 6444.00 y un ticket promedio de 644.40.
-- 2. El producto con ID 1 fue el de mayor facturacion: genero 3600.00
--    con 3 unidades vendidas, aproximadamente el 55.87% del total.
-- 3. Los cinco clientes realizaron 2 pedidos cada uno. El cliente con ID 1
--    fue el que mas gasto, con un total de 2640.00.
