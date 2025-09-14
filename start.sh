set -e

echo "sleep 10s for waiting for the network to be ready..."
sleep 10

echo "Installing Debezium MYSQL CDC Source Connector"
cd /usr/share/confluent-hub-components/
wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/3.2.0.Final/debezium-connector-mysql-3.2.0.Final-plugin.tar.gz
tar -xzf debezium-connector-mysql-3.2.0.Final-plugin.tar.gz
rm debezium-connector-mysql-3.2.0.Final-plugin.tar.gz

echo "Installing JMX Exporter"
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/0.20.0/jmx_prometheus_httpserver-0.20.0.jar

echo "Creating dynamic JMX Exporter config for JMX port ${KAFKA_JMX_PORT}"
cat > /tmp/jmx-exporter-config.yml << EOF
hostPort: localhost:${KAFKA_JMX_PORT}
rules:
  - pattern: "debezium.mysql<type=connector-metrics, context=streaming, server=(.+)><>Connected:"
    name: debezium_mysql_connected
    labels:
      server: "\$1"
    help: "Debezium MySQL Connected Status"
    type: GAUGE
EOF

echo "Starting JMX Exporter HTTP Server on port ${JMX_EXPORTER_PORT}"
java -jar /usr/share/confluent-hub-components/jmx_prometheus_httpserver-0.20.0.jar ${JMX_EXPORTER_PORT} /tmp/jmx-exporter-config.yml &

cd /
/etc/confluent/docker/run &
sleep infinity
