
## Prisma (ORM) を使用するための準備

### Step 1: スキーマファイルの作成

このフォルダに `schema.prisma` というファイルを新規作成して、次の内容を記述して保存してください。

```
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

### Step 2: データベーススキーマの取得

必要に応じて (RDBMS のテーブル構成を更新したときは) `npx prisma db pull` を実行してください。なお、実行前に `npm run db:up` で PostgreSQL コンテナを立ち上げておいてください。

### Step 3: 型情報の生成

**Step.2** を実行したときは `npx prisma generate` を実行してください。このコマンドにより、TypeScript の型定義が最新のスキーマに基づいて生成されます。

### Step 4: VSCodeの再読み込み

**Step.3** を実行したときは VSCode のコマンドパレット (`[Ctrl]+[P]`) から `> Developer: Reload Window` を実行してください。

### Step 5: 利用方法

以上の手順で生成された型情報を利用することで、型安全なデータベース操作が可能になります。

例えば、`s_users` というテーブルが RDBMS に存在しているときは、次のように型情報を参照したり、テーブル操作を行ったりすることができます。

```ts
import type { s_users } from "@prisma/client";
import { prisma } from "@/libs/prisma";

const users: s_users[] = await prisma.s_users.findMany();
console.log(users);
```
