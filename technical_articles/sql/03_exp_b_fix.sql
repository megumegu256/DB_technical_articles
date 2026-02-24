-- ① 一旦、普通のインデックスを削除する
DROP INDEX idx_t_users_email;

-- ② LIKE検索に対応した特別なインデックス（text_pattern_ops）を作成する
CREATE INDEX idx_t_users_email_pattern ON t_users (email text_pattern_ops);

-- ③ もう一度、前方一致検索を実行！
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    email LIKE 'user15%';

-- ④ ちなみに後方一致はどうなるか？
EXPLAIN
ANALYZE
SELECT
    *
FROM
    t_users
WHERE
    email LIKE '%@example.com';