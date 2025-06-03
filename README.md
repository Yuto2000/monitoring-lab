# 🔧 Monitoring Lab - Hello World Tutorial

MacBook Pro M3でPrometheus + Grafanaの監視環境を構築するチュートリアル

<img width="1512" alt="スクリーンショット 2025-06-03 15 23 44" src="https://github.com/user-attachments/assets/c36b7584-5aab-4257-b390-e1c87621298e" />
<img width="1512" alt="スクリーンショット 2025-06-03 15 24 08" src="https://github.com/user-attachments/assets/6ff167c1-9a64-4206-a604-c42aafe36690" />

## 🐳 Docker Compose版（推奨）

### 前提条件
```bash
# Docker Desktopのインストール（MacBook M3対応）
brew install --cask docker
```

### 1. 環境構築（超高速）
```bash
# コンテナ起動（1-2分程度）
docker-compose up -d
```

## 📦 Vagrant版（従来版）

### 前提条件
```bash
# 必要ツールのインストール
brew install vagrant
brew install ansible
brew install --cask virtualbox
```

### 1. 環境構築（自動）
```bash
# VM作成とプロビジョニング（5-10分程度）
vagrant up
```

### 2. 動作確認

#### ✅ Prometheus (メトリクス収集)
- URL: http://localhost:9090
- Status → Targets で node-exporter が UP になっていることを確認

#### ✅ Grafana (ダッシュボード)
- URL: http://localhost:3000
- ログイン: `admin` / `admin`
- Explore → Prometheus → クエリ `up` を実行

#### ✅ Node Exporter (システムメトリクス)
- URL: http://localhost:9100/metrics
- CPU、メモリ、ディスクのメトリクスが表示される

### 3. Hello World グラフ作成

1. Grafana (http://localhost:3000) にログイン
2. **+ → Dashboard → Add new panel**
3. クエリに `up` を入力
4. **Apply** → **Save dashboard**

これでPrometheusから取得したサービス稼働状況がグラフ化されます！

## 📊 Dashboard Testing & Verification

### Access Monitoring Services

After running `docker-compose up -d`, access the following services:

- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Node Exporter**: http://localhost:9100/metrics
- **cAdvisor**: http://localhost:8080
- **Alertmanager**: http://localhost:9093

### Pre-configured Dashboards

1. **Hello World Monitoring Dashboard**
   - **UID**: `hello-world`
   - **Panels**:
     - CPU Usage: Shows system CPU utilization over time
     - Services Status: Displays which services are up/down
     - Memory Usage: Memory consumption monitoring
     - Container Network I/O: Network traffic for containers

2. **Available Metrics**
   - System metrics via Node Exporter
   - Container metrics via cAdvisor
   - Service availability monitoring
   - Custom alert rules for critical thresholds

### Dashboard Verification Steps

1. **Login to Grafana**:
   ```bash
   open http://localhost:3000
   # Login: admin/admin
   ```

2. **Verify Dashboard Loading**:
   - Navigate to "Dashboards" → "Browse"
   - Check for "Hello World Monitoring Dashboard"
   - Verify all panels show data

3. **Test Metrics Collection**:
   ```bash
   # Check Prometheus targets
   open http://localhost:9090/targets

   # Verify metrics are being scraped:
   # - prometheus (self-monitoring)
   # - node-exporter (system metrics)
   # - grafana (application metrics)
   # - cadvisor (container metrics)
   ```

4. **Alert Testing**:
   - View configured alerts: http://localhost:9090/alerts
   - Check Alertmanager: http://localhost:9093
   - Alerts include: High CPU, High Memory, Low Disk, Service Down

### Custom Dashboard Creation

To create additional dashboards:

1. Use Grafana UI to create new dashboards
2. Export JSON configuration
3. Place in `grafana/provisioning/dashboards/` directory
4. Restart services with `docker-compose restart grafana`

### Performance Monitoring

The setup includes comprehensive monitoring with:
- **5-second scrape intervals** for Prometheus and Node Exporter
- **15-second intervals** for Grafana metrics
- **30-second intervals** for cAdvisor (container metrics)
- **Automatic alerting** for critical system conditions

## 🎉 Hello World Tutorial Complete!

### What We've Built

This tutorial has successfully created a complete infrastructure monitoring solution using:

**Core Technologies:**
- ✅ **Vagrant + Ansible**: Infrastructure as Code setup
- ✅ **Docker Compose**: Container orchestration alternative
- ✅ **Prometheus**: Metrics collection and alerting
- ✅ **Grafana**: Visualization and dashboards
- ✅ **Node Exporter**: System metrics
- ✅ **cAdvisor**: Container metrics
- ✅ **Alertmanager**: Alert routing and management

**Key Features Implemented:**
- 🔄 **Multi-interval scraping** (5s-30s based on service type)
- 🚨 **4 alert rules** (CPU, Memory, Disk, Service availability)
- 📊 **Auto-provisioned dashboards** with real-time visualizations
- 🐳 **Container monitoring** with detailed resource tracking
- 🔔 **Webhook-based alerting** with severity levels
- 💾 **Persistent data storage** for metrics and configurations

### Quick Start Demo

1. **Run the health check:**
   ```bash
   ./health-check.sh
   ```

2. **Open monitoring services:**
   - Grafana: http://localhost:3000 (admin/admin)
   - Prometheus: http://localhost:9090
   - cAdvisor: http://localhost:8080

3. **View the Hello World Dashboard:**
   - Login to Grafana
   - Navigate to "Hello World Monitoring Dashboard"
   - Observe real-time metrics for CPU, Memory, Services, and Network

### Advanced Usage

**Add custom metrics:**
```bash
# Edit prometheus/prometheus.yml to add new scrape targets
# Restart: docker-compose restart prometheus
```

**Create new dashboards:**
```bash
# Add JSON files to grafana/provisioning/dashboards/
# Restart: docker-compose restart grafana
```

**Modify alert rules:**
```bash
# Edit prometheus/alert-rules.yml
# Restart: docker-compose restart prometheus alertmanager
```

### Cleanup

```bash
# Stop all services
docker-compose down

# Remove volumes (optional)
docker-compose down -v

# For Vagrant cleanup
vagrant destroy
```

---

**🎓 Congratulations!** You've successfully built and deployed a production-ready monitoring infrastructure that can scale from development to enterprise environments.

## 🏗️ アーキテクチャ

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Grafana   │───▶│  Prometheus  │───▶│Node Exporter│
│   :3000     │    │    :9090     │    │   :9100     │
│ (Dashboard) │    │ (Collector)  │    │ (Metrics)   │
└─────────────┘    └──────────────┘    └─────────────┘
```

## 🧹 クリーンアップ

```bash
vagrant halt        # VM停止
vagrant destroy -f  # VM削除
```

## 📚 学習ポイント

- **Vagrant**: ARM64対応仮想環境の構築
- **Ansible**: Infrastructure as Codeによる自動化
- **Prometheus**: Pull型メトリクス収集の基礎
- **Grafana**: 監視ダッシュボードの作成

## 🔍 トラブルシューティング

### Vagrant起動エラー
```bash
# VirtualBox ARM64版が正しくインストールされているか確認
vboxmanage --version
```

### サービス状態確認
```bash
vagrant ssh
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status node-exporter
```

## 🎯 Final Status & Resolution

### ✅ Issue Resolution: Dashboard Data Display

**Problem**: Hello World dashboard was showing "No data" for all panels

**Root Cause**: Datasource UID mismatch between dashboard configuration and Grafana datasource

**Solution Applied**:
1. **Fixed datasource UID**: Updated `grafana/provisioning/datasources/prometheus.yml` to specify `uid: prometheus`
2. **Restarted Grafana**: Applied the datasource configuration changes
3. **Verified connectivity**: All queries now return data successfully

### 📊 Current Monitoring Status

```bash
# Run the demo to see live status
./demo.sh

# Test specific queries
./test-queries.sh

# Full health check
./health-check.sh
```

**Active Services**:
- ✅ **Prometheus**: Collecting metrics from 4 targets
- ✅ **Grafana**: 2 dashboards with live data visualization
- ✅ **Node Exporter**: System metrics (CPU: ~2%, Memory: ~52%)
- ✅ **cAdvisor**: Container metrics and monitoring
- ✅ **Alertmanager**: 4 alert rules configured and active

**Available Dashboards**:
- 🎯 **Hello World Monitoring**: http://localhost:3000/d/hello-world
- 📊 **System Monitoring**: http://localhost:3000/d/system-monitoring-uid

### 🔧 Quick Troubleshooting Commands

```bash
# Check service status
docker-compose ps

# Verify Prometheus targets
curl "http://localhost:9090/api/v1/targets" | jq '.data.activeTargets[].health'

# Test Grafana datasource
curl -u admin:admin "http://localhost:3000/api/datasources" | jq '.[].uid'

# View container logs
docker-compose logs grafana
docker-compose logs prometheus
```

### 🎉 Tutorial Complete!

Your infrastructure monitoring lab is now fully operational with:
- 📈 **Real-time metrics collection** and visualization
- 🚨 **Automated alerting** for critical system conditions  
- 🐳 **Container monitoring** with detailed resource tracking
- 🔄 **Multi-service orchestration** via Docker Compose
- 📊 **Custom dashboards** with live data feeds

**Next Steps**: Explore the dashboards, create custom panels, and experiment with alert thresholds!
