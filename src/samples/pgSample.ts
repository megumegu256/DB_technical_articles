// from-teacher/03/init-s_users.sql が実行されていることを前提としています

import "dotenv/config";
import { Client } from "pg";

const connectionString = process.env.DATABASE_URL;
if (!connectionString) throw new Error("DATABASE_URL is missing");

const client = new Client({
  connectionString,
});

// 接続文字列を使わずに接続設定を個別に指定する場合
// const client = new Client({
//   host: "localhost",
//   user: "student",
//   password: "secret123",
//   database: "playground",
//   port: 5432,
// });

await client.connect();

const r = await client.query("SELECT * FROM s_users");
console.log(r.rows);

await client.end();
