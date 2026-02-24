-- 個人の売上と、部署の合計売上を横に並べ、構成比を計算する
SELECT
    department,
    employee_name,
    amount AS personal_amount,
    -- 部署内の合計売上を計算（ORDER BYがない点に注意）
    SUM(amount) OVER (
        PARTITION BY
            department
    ) AS dept_total,
    -- 構成比の計算（個人売上 ÷ 部署合計 × 100）
    ROUND(
        amount * 100.0 / SUM(amount) OVER (
            PARTITION BY
                department
        ),
        1
    ) AS ratio_pct
FROM
    sales_records
WHERE
    sales_month = '2024-06'
ORDER BY
    department,
    amount DESC;