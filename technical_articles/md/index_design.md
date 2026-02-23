# 記事本文（改善案）

## 0. この記事のゴール

* インデックス設計の目的とトレードオフを説明できる
* B-treeインデックスの仕組みと探索コストの考え方を理解する
* PostgreSQL 17で `EXPLAIN / EXPLAIN ANALYZE` を使い、効果を測定できる
* 「インデックスが効かないケース」を実験を通じて体感し、適切な設計ができるようになる

## 1. インデックス設計とは何か

インデックス設計は、「よく使うクエリに対して、どの列にどの種類のインデックスを作るか」を決める作業である。目的は、検索・結合・並べ替え・集計などの処理コストを下げること。

### 1.1 インデックスとB-treeの仕組み

* PostgreSQLの標準インデックスは「B-tree（Balanced Tree）」というデータ構造である。
* ルート（根）からブランチ（枝）をたどり、目的のデータがあるリーフ（葉）へ到達する木構造になっている。
* B-treeは常にデータがソートされた状態を保つため、探索コストはおおむね  となる。
* 先頭から1行ずつ探す全件走査（Seq Scan）のコスト  と比べて、データ量が多いほど、また条件に合う行が少ないほど圧倒的に有利になる。

### 1.2 インデックスのコスト（トレードオフ）

* `INSERT` / `UPDATE` / `DELETE` のたびに、インデックスの木構造も並べ替えて更新する必要がある。
* つまり「読み取り（SELECT）性能を上げる代わりに、書き込みコストとディスク容量が増える」という明確なトレードオフが存在する。

## 2. インデックスの種類と特徴（PostgreSQL）

* **B-tree:** 等値検索、範囲検索（`<`, `>`, `BETWEEN`）、`ORDER BY` に強い。実務の9割はこれ。
* **Hash:** 等値検索のみ。
* **GiST / GIN:** 全文検索やJSONB、配列、位置情報などに使用。
* **BRIN:** 物理順序が保持される巨大なログテーブルなどに有効。

## 3. インデックス設計の基本原則

1. **まずクエリを知る**
* `WHERE` / `JOIN` / `ORDER BY` に頻出する列をターゲットにする。


2. **選択度（Selectivity）を考える**
* 条件で「全体の何％まで絞り込めるか」が重要。
* 性別やステータスなど、値の種類が少ない（カーディナリティが低い）列は効果が薄い。


3. **複合インデックスの順序**
* `(A, B)` と `(B, A)` は全く異なる。
* 電話帳が「苗字→名前」の順に並んでいるのと同じで、第一条件（A）で大きく絞り込める順序にするのが鉄則。


4. **過剰なインデックスを作らない**
* 実測で効果を確認してから追加する。



## 4. 実行計画の確認方法（EXPLAIN の見方）

実験に入る前に、PostgreSQLがどのようにクエリを実行しているかを確認する `EXPLAIN` の読み方を押さえる。

```sql
EXPLAIN ANALYZE SELECT * FROM t_users WHERE email = 'test@example.com';

```

* **Seq Scan:** テーブルを先頭から全件走査している（インデックスが使われていない）。
* **Index Scan:** インデックスを使って効率よく検索している。
* **cost=0.00..xxx:** 推定コスト（右側の数値が全体の処理コスト）。
* **actual time=xxx..yyy:** 実際の実行時間（ミリ秒単位）。ここがどう減るかに注目する。

## 5. 実験: インデックスの挙動と効果を検証する

### 5.1 環境と準備

* PostgreSQL 17 (Dockerコンテナ)
* 実行: `npm run db:up` など（※講義の環境に合わせて記載）

### 5.2 検証用データセットの作成

インデックスの様々な挙動を確かめるため、20万件のダミーデータを作成する。ステータス（active/inactive）には意図的に偏りを持たせる。

```sql
DROP TABLE IF EXISTS t_users;
CREATE TABLE t_users (
    id serial PRIMARY KEY,
    email text NOT NULL,
    age int NOT NULL,
    status text NOT NULL,
    created_at timestamp NOT NULL
);

INSERT INTO t_users (email, age, status, created_at)
SELECT
    'user' || i || '@example.com',
    (random() * 60)::int + 18,
    -- 90%を 'active', 10%を 'inactive' にする
    CASE WHEN random() < 0.9 THEN 'active' ELSE 'inactive' END,
    now() - (random() * interval '365 days')
FROM generate_series(1, 200000) AS s(i);

```

### 5.3 実験A: 基本的な Index Scan（等値検索）

1. インデックスなしで `user150000@example.com` を検索（`EXPLAIN ANALYZE` を使用）。
2. `email` 列にインデックスを作成: `CREATE INDEX idx_t_users_email ON t_users (email);`
3. 再度同じ検索を実行し、`Seq Scan` から `Index Scan` に変わり、実行時間が劇的に短縮されることを確認する。

### 5.4 実験B: インデックスが効かないケース①（LIKE検索）

B-treeは辞書順に並んでいるため、検索の仕方によってはインデックスが使えない。

1. 前方一致: `WHERE email LIKE 'user15%'` を実行（Index Scanになるはず）。
2. 後方一致: `WHERE email LIKE '%@example.com'` を実行（Seq Scanになるはず）。
**【考察】** 最初の文字がわからないと、B-treeの木をたどれないことを確認。

### 5.5 実験C: インデックスが効かないケース②（選択度の問題）

1. `status` 列にインデックスを作成: `CREATE INDEX idx_t_users_status ON t_users (status);`
2. 少数派の検索: `WHERE status = 'inactive'` を実行（Index Scanが選ばれやすい）。
3. 多数派の検索: `WHERE status = 'active'` を実行（Seq Scanになる可能性が高い）。
**【考察】** ヒットする件数が多すぎる場合、オプティマイザは「インデックスをたどって実データを読むより、最初からテーブル全体を読んだ方がマシ」と判断する。

### 5.6 実験D: 複合インデックスの順序

1. `(age, created_at)` の順で複合インデックスを作成。
2. `WHERE age = 30 AND created_at > '2025-01-01'` で検索（Index Scanになる）。
3. `WHERE created_at > '2025-01-01'` だけで検索（Seq Scanになる）。
**【考察】** 複合インデックスは左側の列から順にソートされるため、第1列（age）の条件がないと機能しないことを確認。

## 6. 結果と考察まとめ

* インデックスは万能ではない。B-treeの構造上、前方一致や完全一致でなければ効果が薄い。
* 条件に合致するデータが多すぎる（選択度が悪い）と、PostgreSQLのオプティマイザはあえてインデックスを無視する。
* 複合インデックスは列の順序が命。WHERE句で必ず指定され、かつ最も絞り込める列を先頭にする。

## 7. 演習（解答例つき）

**問題1**
次のクエリを高速化したい。どの列に、どのような順序で複合インデックスを作るべきか。

```sql
SELECT * FROM t_users
WHERE status = 'inactive' AND age = 25
ORDER BY created_at DESC
LIMIT 50;

```

**解答例**
`status` よりも `age` の方が選択度が高い（種類が多い＝絞り込める）ため、`age` を先頭にするのがセオリー。また `ORDER BY` のソート処理もスキップさせるために `created_at` も含める。

```sql
CREATE INDEX idx_users_age_status_created 
ON t_users (age, status, created_at DESC);

```

**問題2**
※JOINクエリのインデックス設計問題（元の案のまま配置）

## 8. まとめ

* インデックス設計は「クエリ中心」で考える
* EXPLAIN ANALYZEで、「自分の意図通りにIndex Scanが使われているか」を必ず検証する
* 便利な反面、書き込みコスト増と容量増のトレードオフがあることを忘れない