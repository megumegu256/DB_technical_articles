-- 部署ごとに順位をリセットして計算する
SELECT
    department,
    employee_name,
    amount,
    RANK() OVER (
        PARTITION BY
            department
        ORDER BY
            amount DESC
    ) AS dept_rank
FROM
    sales_records
WHERE
    sales_month = '2024-05';