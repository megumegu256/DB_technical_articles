-- RANK, DENSE_RANK, ROW_NUMBER の違いを確認する
SELECT
    employee_name,
    amount,
    RANK() OVER (
        ORDER BY
            amount DESC
    ) AS "rank",
    DENSE_RANK() OVER (
        ORDER BY
            amount DESC
    ) AS "dense_rank",
    ROW_NUMBER() OVER (
        ORDER BY
            amount DESC
    ) AS "row_number"
FROM
    sales_records
WHERE
    sales_month = '2024-04';