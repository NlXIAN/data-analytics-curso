-- Pre-entrega 5: Consultas con JOINs para el proyecto RetailPro
-- Cruzando tablas para enriquecer el analisis
-- Base de datos: Ventas_Tech_DB

USE Ventas_Tech_DB;
GO

-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Proposito: reunir los datos de ventas con la informacion de clientes,
-- productos y categorias para analizar las operaciones del negocio.
SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad,
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;

-- Hallazgo: Las 10 ventas de marzo de 2024 se pueden relacionar con
-- sus clientes, productos y categorias; juntas suman 6444.00 de facturacion.

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Proposito: identificar clientes registrados sin compras para el area de CRM.
SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.id_cliente;

-- Hallazgo: No aparecen clientes sin compras: los 5 clientes registrados
-- tienen al menos una venta. CRM no tiene clientes inactivos en esta muestra.

-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Proposito: encontrar productos del catalogo sin movimiento comercial.
SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.id_producto;

-- Hallazgo: No aparecen productos sin ventas: los 6 productos del catalogo
-- registran movimientos. El area de producto no detecta articulos sin vender.

-- Consulta 4: Consolidado por origen (UNION ALL)
-- Proposito: comparar la facturacion de dos periodos de marzo de 2024.
-- El origen se identifica con una etiqueta creada en cada SELECT.
SELECT
    consolidado.canal,
    SUM(consolidado.total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Marzo 1 al 10' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-01'
      AND fecha_venta < '2024-03-11'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Marzo 11 al 31' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
      AND fecha_venta < '2024-04-01'
) AS consolidado
GROUP BY consolidado.canal
ORDER BY total_canal DESC;

-- Hallazgo: Del 1 al 10 de marzo se facturaron 3620.00, frente a 2824.00
-- del 11 al 31. El primer periodo genero 796.00 mas de facturacion.
