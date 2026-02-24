-- 社員ごとに時系列で並べ、1つ前の行の値を取得する
SELECT
    employee_name,
    sales_month,
    amount AS current_amount,
    -- PARTITION BY で社員ごとに分割し、sales_month 順に並べた際の「1つ前の行」を取得
    LAG(amount) OVER (
        PARTITION BY
            employee_name
        ORDER BY
            sales_month
    ) AS prev_amount,
    -- 前月との差額
    amount - LAG(amount) OVER (
        PARTITION BY
            employee_name
        ORDER BY
            sales_month
    ) AS diff
FROM
    sales_records
WHERE
    employee_name = '佐藤' OR
    employee_name = '伊藤'
ORDER BY
    employee_name,
    sales_month;