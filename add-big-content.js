const mysql = require("mysql2/promise");

async function main() {
  const connection = await mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "test",
    database: "test",
  });

  const veryBigContent = "a".repeat(12 * 1024 * 1024);
  await connection.execute("INSERT INTO Something (content) VALUES (?)", [
    veryBigContent,
  ]);

  connection.end();
}

main();
