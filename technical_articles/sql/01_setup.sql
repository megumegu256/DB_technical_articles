DROP TABLE IF EXISTS t_users;

CREATE TABLE t_users (
    id serial PRIMARY KEY,
    email text NOT NULL,
    age int NOT NULL,
    status text NOT NULL,
    created_at timestamp NOT NULL
);

INSERT INTO
    t_users (email, age, status, created_at)
SELECT
    'user' || i || '@example.com',
    (RANDOM() * 60)::int + 18,
    CASE
        WHEN RANDOM() < 0.9 THEN 'active'
        ELSE 'inactive'
    END,
    NOW() - (RANDOM() * interval '365 days')
FROM
    GENERATE_SERIES(1, 200000) AS s (i);