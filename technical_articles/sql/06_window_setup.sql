-- 既存のテーブルがあれば削除
DROP TABLE IF EXISTS sales_records;

-- 売上管理テーブルの作成
CREATE TABLE sales_records (
    id serial PRIMARY KEY,
    sales_month text NOT NULL,
    department text NOT NULL,
    employee_name text NOT NULL,
    amount int NOT NULL
);

-- 15件のテストデータを挿入
INSERT INTO
    sales_records (sales_month, department, employee_name, amount)
VALUES
    ('2024-04', '第1営業部', '佐藤', 500),
    ('2024-04', '第1営業部', '鈴木', 800),
    ('2024-04', '第1営業部', '高橋', 800),
    ('2024-04', '第2営業部', '田中', 450),
    ('2024-04', '第2営業部', '伊藤', 700),
    ('2024-05', '第1営業部', '佐藤', 600),
    ('2024-05', '第1営業部', '鈴木', 900),
    ('2024-05', '第1営業部', '高橋', 850),
    ('2024-05', '第2営業部', '田中', 500),
    ('2024-05', '第2営業部', '伊藤', 750),
    ('2024-06', '第1営業部', '佐藤', 550),
    ('2024-06', '第1営業部', '鈴木', 850),
    ('2024-06', '第1営業部', '高橋', 900),
    ('2024-06', '第2営業部', '田中', 600),
    ('2024-06', '第2営業部', '伊藤', 800);