# DB 技術記事 開発環境メモ（課題2: インデックス設計）

本リポジトリでは、課題2「インデックス設計」のハンズオン検証用に、PostgreSQL 17 の Docker コンテナ環境をセットアップしました。ここまでの活動内容と、再現手順を記します。

## 環境概要
- 取得した演習環境: C:\DB-2025-PostgreSQL（履歴なし運用）
- コンテナ: `postgres`（pg17）、`dbgate`
- ポート: PostgreSQL 5432、DbGate 8080
- DB 接続情報（compose 設定より）
	- ユーザ: `student`
	- パスワード: `secret123`
	- データベース: `playground`

## 実施した作業（履歴を持たない取得と起動）
1. リモート履歴を持たない形で演習環境を取得（ZIP相当の運用）
	 - `git clone --depth=1` で最小履歴取得後、`.git` を削除してリモート接続情報を除去。
2. Docker Desktop を起動（Windows）
3. Docker Compose でコンテナを起動（`postgres` と `dbgate`）
4. 接続確認（正しい認証で `student`/`playground` に接続できることを確認）

## 再現手順（PowerShell）
以下のコマンドで同じ状態を再現できます。

```powershell
# 1) 取得と履歴の削除（C:\ 直下に配置）
Push-Location C:\
git clone --depth=1 https://github.com/TakeshiWada1980/DB-2025-PostgreSQL.git C:\DB-2025-PostgreSQL
Remove-Item -Recurse -Force C:\DB-2025-PostgreSQL\.git
Pop-Location

# 2) Docker Desktop を起動（必要に応じて）
$dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerPath) { Start-Process $dockerPath }

# 3) コンテナ起動と状態確認
docker compose -f C:\DB-2025-PostgreSQL\docker\docker-compose.yaml up -d
docker compose -f C:\DB-2025-PostgreSQL\docker\docker-compose.yaml ps

# 4) 接続確認（PostgreSQL コンテナ内から）
docker exec pg17 psql -U student -d playground -c "SELECT current_user, current_database(), version();"
```

## 参考（Compose 設定の要点）
- サービス定義は `postgres` と `dbgate`。
- 環境変数（PostgreSQL）
	- `POSTGRES_USER=student`
	- `POSTGRES_PASSWORD=secret123`
	- `POSTGRES_DB=playground`
- ポート公開
	- `5432:5432`（PostgreSQL）
	- `8080:3000`（DbGate）

## 次のステップ（課題2: インデックス設計）
- データ準備とベースライン計測（インデックスなしで `EXPLAIN ANALYZE`）
- インデックス作成（単一・複合・部分インデックス）と再計測
- 実行計画の比較（Seq Scan / Index Scan / Index Only Scan 等）
- 演習問題と解答例の作成（記事に添付）

記事公開後、Teams「DB-課題2」に URL を提出します。
