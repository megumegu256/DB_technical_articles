-- ROLLUPを使って小計と総合計を出す
SELECT
    sales_month,
    department,
    SUM(amount) AS total_amount,
    -- GROUPING関数は、その列が集約（ROLLUP等で計算）されてできたNULLなら「1」を返す
    GROUPING(sales_month) AS is_month_total,
    GROUPING(department) AS is_dept_total
FROM
    sales_records
GROUP BY
    ROLLUP (sales_month, department)
ORDER BY
    sales_month,
    department;