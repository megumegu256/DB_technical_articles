-- ① 複合インデックスを作成する（第1条件: age, 第2条件: created_at）
CREATE INDEX idx_t_users_age_created ON t_users (age, created_at);

-- ② 第1列と第2列の両方を使って検索する（インデックスが効くはず）
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    age = 30 AND
    created_at > '2024-01-01';

-- ③ 第2列のみを使って検索する（インデックスが効かないはず）
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    created_at > '2024-01-01';