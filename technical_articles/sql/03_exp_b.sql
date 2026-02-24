-- ① 前方一致検索（インデックスが効くはず）
-- 'user15' から始まるアドレスを検索します。
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    email LIKE 'user15%';

-- ② 後方一致検索（インデックスが効かないはず）
-- '@example.com' で終わるアドレスを検索します。
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    email LIKE '%@example.com';