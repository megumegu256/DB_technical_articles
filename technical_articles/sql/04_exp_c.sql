-- ① status列にインデックスを作成する
CREATE INDEX idx_t_users_status ON t_users (status);

-- ② 少数派（全体の約10%）の検索
-- ヒット件数が少ないため、インデックスが有効に働くはずです。
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    status = 'inactive';

-- ③ 多数派（全体の約90%）の検索
-- ヒット件数が多すぎるため、インデックスがあるのに無視されるはずです。
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    status = 'active';