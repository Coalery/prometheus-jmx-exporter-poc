#!/bin/sh

# 커넥터 생성
echo "✨ test 데이터베이스 커넥터 생성 시작"
curl -X POST 'http://connect-1:8083/connectors' \
  --silent \
  --output /dev/null \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "cdc-test-connector",
    "config": {
      "connector.class": "io.debezium.connector.mysql.MySqlConnector",
      "tasks.max": "1",
      "database.hostname": "mysql-test",
      "database.port": "3306",
      "database.user": "debezium_user",
      "database.password": "test",
      "database.server.id": "101",
      "topic.prefix": "development",
      "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
      "schema.history.internal.kafka.topic": "schema-changes.inventory",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": false,
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": false,
      "database.include.list": "test",
      "custom.metric.tags": "database=test"
    }
  }'
echo "✅ 커넥터 생성 완료!"

# 커넥터 생성
echo "✨ other 데이터베이스 커넥터 생성 시작"
curl -X POST 'http://connect-2:8083/connectors' \
  --silent \
  --output /dev/null \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "cdc-other-connector",
    "config": {
      "connector.class": "io.debezium.connector.mysql.MySqlConnector",
      "tasks.max": "1",
      "database.hostname": "mysql-test",
      "database.port": "3306",
      "database.user": "debezium_user",
      "database.password": "test",
      "database.server.id": "102",
      "topic.prefix": "development",
      "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
      "schema.history.internal.kafka.topic": "schema-changes.inventory",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": false,
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": false,
      "database.include.list": "other",
      "custom.metric.tags": "database=other"
    }
  }'
echo "✅ 커넥터 생성 완료!"

echo "✨ 커넥터 초기화 대기 중..."
sleep 5

# 커넥터 상태 확인
echo "✨ 커넥터 상태 확인 중..."
curl -s http://connect-1:8083/connectors/cdc-test-connector/status | grep -q '"state":"RUNNING"' && {
    echo "✅ test 커넥터 생성 및 실행 완료!"
} || {
    echo "❌ test 커넥터 생성 실패"
    CONNECTOR_STATUS=$(curl -s http://connect-1:8083/connectors/cdc-test-connector/status)
    echo "현재 커넥터 상태: $CONNECTOR_STATUS"
}

curl -s http://connect-2:8083/connectors/cdc-other-connector/status | grep -q '"state":"RUNNING"' && {
    echo "✅ other 커넥터 생성 및 실행 완료!"
} || {
    echo "❌ other 커넥터 생성 실패"
    CONNECTOR_STATUS=$(curl -s http://connect-2:8083/connectors/cdc-other-connector/status)
    echo "현재 커넥터 상태: $CONNECTOR_STATUS"
}
