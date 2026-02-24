-- ① インデックス作成前の検索（Seq Scanになるはず）
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    email = 'user150000@example.com';

-- ② インデックスの作成
CREATE INDEX idx_t_users_email ON t_users (email);

-- ③ インデックス作成後の検索（Index Scanになるはず）
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    email = 'user150000@example.com';