// 간단한 헬스체크 함수
async function checkConnectorHealth() {
  const response = await fetch(
    "http://localhost:9090/api/v1/query?query=debezium_mysql_connected"
  );
  const data = await response.json();

  const connectors = data.data.result.map((result) => ({
    server: result.metric.server,
    instance: result.metric.instance,
    connected: result.value[1] === "1",
    timestamp: new Date(result.value[0] * 1000),
  }));

  return connectors;
}

// 사용 예시
setInterval(() => {
  checkConnectorHealth().then((connectors) => {
    console.log(new Date());
    console.log("Connector Status:");
    connectors.forEach((c) => {
      console.log(
        `- ${c.server}: ${c.connected ? "✅ Connected" : "❌ Disconnected"}`
      );
    });
  });
}, 5000);
