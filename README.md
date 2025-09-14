# Kafka Connect Distributed Mode JMX Monitoring

Kafka Connect distributed mode에서 여러 Debezium connector의 JMX 메트릭을 중앙 집중화하여 모니터링하는 시스템입니다.

## Run

```shell
docker compose up -d
npm run start
```

## 🏗️ Architecture

```mermaid
graph TB
    subgraph "MySQL Database"
        DB[(MySQL<br/>mysql-test:3306)]
    end

    subgraph "Kafka Ecosystem"
        ZK[Zookeeper<br/>:2181]
        K[Kafka<br/>:9092]
    end

    subgraph "Kafka Connect Cluster"
        C1[Connect-1<br/>:8083<br/>cdc-test-connector]
        C2[Connect-2<br/>:8084<br/>cdc-other-connector]
        C3[Connect-3<br/>:8085<br/>standby]
    end

    subgraph "JMX Exporters"
        JMX1[JMX Exporter<br/>:8081]
        JMX2[JMX Exporter<br/>:8082]
        JMX3[JMX Exporter<br/>:8087]
    end

    subgraph "Monitoring"
        PROM[Prometheus<br/>:9090]
        GRAF[Grafana<br/>:3000]
    end

    subgraph "Management"
        KUI[Kafka UI<br/>:8080]
    end

    %% Database connections
    DB -.->|CDC| C1
    DB -.->|CDC| C2

    %% Kafka connections
    ZK --> K
    C1 --> K
    C2 --> K
    C3 --> K

    %% JMX connections
    C1 -->|JMX :9012| JMX1
    C2 -->|JMX :9013| JMX2
    C3 -->|JMX :9014| JMX3

    %% Prometheus scraping
    JMX1 -->|/metrics| PROM
    JMX2 -->|/metrics| PROM
    JMX3 -->|/metrics| PROM

    %% Grafana connection
    PROM --> GRAF

    %% Management UI
    K --> KUI

    style C1 fill:#e1f5fe
    style C2 fill:#e1f5fe
    style C3 fill:#f3e5f5
    style JMX1 fill:#fff3e0
    style JMX2 fill:#fff3e0
    style JMX3 fill:#fff3e0
    style PROM fill:#e8f5e8
```
