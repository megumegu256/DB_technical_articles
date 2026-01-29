import "dotenv/config";
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const connectionString = process.env.DATABASE_URL;
if (!connectionString) throw new Error("DATABASE_URL is missing");

const pool = new Pool({
  connectionString,
  options: "-c search_path=public",
});

// 接続文字列を使わずに接続設定を個別に指定する場合
// const pool = new Pool({
//   host: "localhost",
//   user: "student",
//   password: "secret123",
//   database: "playground",
//   port: 5432,
// });

export const db = drizzle(pool);
