-- Warehouse Performance Analysis
-- Tools: PostgreSQL
-- Purpose: Analyse warehouse productivity, employee performance,
-- manager performance and data quality.

-- 1. Overall warehouse performance
SELECT
    SUM(orders) AS total_orders,
    SUM(errors) AS total_errors,
    SUM(hours) AS total_hours,
    ROUND(SUM(orders)::numeric / SUM(hours), 2) AS orders_per_hour
FROM warehouse_data;


-- 2. Performance by department
SELECT
    department,
    COUNT(employee) AS employee_count,
    SUM(orders) AS total_orders,
    ROUND(AVG(orders), 2) AS avg_orders
FROM warehouse_data
GROUP BY department
ORDER BY total_orders DESC;


-- 3. Night shift performance by department
SELECT
    department,
    COUNT(employee) AS employee_count,
    SUM(orders) AS total_orders,
    ROUND(AVG(orders), 2) AS avg_orders
FROM warehouse_data
WHERE shift = 'Night'
GROUP BY department
HAVING SUM(orders) >= 300
ORDER BY total_orders DESC;


-- 4. Manager performance in Warrington
SELECT
    e.manager,
    COUNT(w.employee) AS employee_count,
    SUM(w.orders) AS total_orders
FROM warehouse_data w
INNER JOIN employee_info e
    ON w.employee_id = e.employee_id
WHERE w.shift = 'Night'
    AND e.location = 'Warrington'
GROUP BY e.manager
HAVING SUM(w.orders) >= 300
ORDER BY total_orders DESC;


-- 5. Identify warehouse employees with missing employee information
SELECT
    w.employee_id,
    w.employee,
    e.manager,
    e.location
FROM warehouse_data w
LEFT JOIN employee_info e
    ON w.employee_id = e.employee_id
WHERE e.employee_id IS NULL;


-- 6. Employees performing above the company average
WITH company_average AS (
    SELECT AVG(orders) AS avg_orders
    FROM warehouse_data
)
SELECT
    employee,
    orders
FROM warehouse_data
WHERE orders > (
    SELECT avg_orders
    FROM company_average
)
ORDER BY orders DESC;
