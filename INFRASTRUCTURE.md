# 🐳 Docker監視インフラ構成図

## 📊 全体アーキテクチャ概要

この監視システムは、Prometheus、Grafana、Alertmanagerを中核とした包括的なDocker監視環境です。5つのコンテナが連携して、システムメトリクス収集、可視化、アラート管理を実現しています。

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           macOS ホストシステム (M3 MacBook Pro)                        │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │                    Docker監視ネットワーク                                       │    │
│  │                  (monitoring bridge network)                                │    │
│  │                                                                             │    │
│  │           ┌─────────────────────────────────────────────────┐               │    │
│  │           │              監視データフロー                     │               │    │
│  │           └─────────────────────────────────────────────────┘               │    │
│  │                                                                             │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │    │
│  │  │ Prometheus  │◄───┤ Grafana     │◄───┤ ユーザー     │                     │    │
│  │  │ :9090       │    │ :3000       │    │ ブラウザ     │                     │    │
│  │  │             │    │             │    │             │                     │    │
│  │  │ [メトリクス  │    │ [ダッシュ     │    │ [可視化]     │                     │    │
│  │  │  収集・保存] │    │  ボード]    │    │             │                     │    │
│  │  │             │    │ ・Hello     │    │ HTTP:3000   │                     │    │
│  │  │ TSDB 200h   │    │ ・System    │    │             │                     │    │
│  │  └─────────────┘    └─────────────┘    └─────────────┘                     │    │
│  │         ▲                    ▲                                              │    │
│  │         │                    │                                              │    │
│  │    メトリクス収集        データソース接続                                       │    │
│  │         │                    │                                              │    │
│  │         │              ┌─────┴─────┐                                        │    │
│  │         │              │UID:       │                                        │    │
│  │         │              │prometheus │                                        │    │
│  │         │              └───────────┘                                        │    │
│  │         │                                                                   │    │
│  │  ┌──────┴─────┬─────────────┬─────────────┬─────────────┐                  │    │
│  │  │ 5s間隔     │ 5s間隔      │ 30s間隔     │ 10s間隔     │                  │    │
│  │  ▼            ▼             ▼             ▼             ▼                  │    │
│  │ ┌────────────┐ ┌──────────┐ ┌───────────┐ ┌───────────┐ ┌─────────────┐   │    │
│  │ │Node        │ │cAdvisor  │ │Grafana    │ │Prometheus │ │Alertmanager │   │    │
│  │ │Exporter    │ │:8080     │ │Self       │ │Self       │ │:9093        │   │    │
│  │ │:9100       │ │          │ │:3000      │ │:9090      │ │             │   │    │
│  │ │            │ │privileged│ │           │ │           │ │             │   │    │
│  │ │[システム    │ │[コンテナ  │ │[アプリ     │ │[サービス   │ │[アラート     │   │    │
│  │ │ メトリクス] │ │ メトリクス]│ │メトリクス] │ │メトリクス] │ │ 管理]       │   │    │
│  │ │            │ │          │ │           │ │           │ │             │   │    │
│  │ │・CPU使用率  │ │・メモリ   │ │・HTTP     │ │・ストレージ │ │・ルーティング│   │    │
│  │ │・メモリ使用 │ │・ネット   │ │・DB接続   │ │・クエリ性能│ │・通知管理   │   │    │
│  │ │・ディスク   │ │・ファイル │ │・レスポンス│ │・スクレイプ│ │・グループ化 │   │    │
│  │ │・ネットワーク│ │・プロセス │ │時間       │ │状態       │ │・抑制制御   │   │    │
│  │ └────────────┘ └──────────┘ └───────────┘ └───────────┘ └─────────────┘   │    │
│  │      │              │                                        ▲            │    │
│  │      │              │                                        │            │    │
│  │      │              └─────────┐                      アラート送信          │    │
│  │      │                        │                              │            │    │
│  │      │                        ▼                              │            │    │
│  │      │              ┌─────────────────┐                     │            │    │
│  │      │              │ Dockerエンジン   │                     │            │    │
│  │      │              │ ・コンテナ監視   │                     │            │    │
│  │      │              │ ・リソース監視   │              ┌──────┴────────┐   │    │
│  │      │              │ ・ログ収集      │              │ アラートルール  │   │    │
│  │      │              └─────────────────┘              │                │   │    │
│  │      │                                               │ 1.高CPU使用率   │   │    │
│  │      └──────┐                                        │   >80% (5分間) │   │    │
│  │             │                                        │ 2.高メモリ使用  │   │    │
│  │             ▼                                        │   >85% (5分間) │   │    │
│  │    ┌─────────────────┐                              │ 3.ディスク不足  │   │    │
│  │    │ ホストシステム    │                              │   >90% (1分間) │   │    │
│  │    │ ・/proc         │                              │ 4.サービス停止  │   │    │
│  │    │ ・/sys          │                              │   (1分間)      │   │    │
│  │    │ ・/rootfs       │                              └───────────────┘   │    │
│  │    │ ・ファイルシステム│                                                   │    │
│  │    └─────────────────┘                                                   │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## 🔧 サービス詳細構成

### 1. **Prometheus Server** (中央メトリクス収集エンジン)
```
┌─────────────────────────────────────────────────────────────┐
│                    Prometheus :9090                        │
├─────────────────────────────────────────────────────────────┤
│ 機能:                                                       │
│ ✓ メトリクス収集・保存 (TSDB 200h保持)                        │
│ ✓ アラートルール評価 (15s間隔)                               │
│ ✓ スクレイプ設定管理                                        │
│ ✓ PromQL クエリエンジン                                     │
├─────────────────────────────────────────────────────────────┤
│ スクレイプターゲット:                                        │
│ • prometheus:9090    (5s間隔)                              │
│ • node-exporter:9100 (5s間隔)                              │
│ • grafana:3000       (30s間隔)                             │
│ • cadvisor:8080      (10s間隔)                             │
├─────────────────────────────────────────────────────────────┤
│ 永続化:                                                     │
│ • prometheus_data volume (/prometheus)                     │
│ • 設定ファイル (./prometheus:/etc/prometheus)                │
│ • アラートルール (alert-rules.yml)                          │
└─────────────────────────────────────────────────────────────┘
```

### 2. **Grafana Dashboard** (可視化フロントエンド)
```
┌─────────────────────────────────────────────────────────────┐
│                     Grafana :3000                          │
├─────────────────────────────────────────────────────────────┤
│ 機能:                                                       │
│ ✓ ダッシュボード可視化                                       │
│ ✓ アラート通知表示                                          │
│ ✓ ユーザー管理 (admin/admin)                                │
│ ✓ プロビジョニング自動化                                     │
├─────────────────────────────────────────────────────────────┤
│ ダッシュボード:                                             │
│ • Hello World Monitoring (基本4パネル)                      │
│   - CPU使用率、メモリ使用率                                  │
│   - ディスク使用量、ネットワークI/O                          │
│ • System Monitoring (詳細システム監視)                      │
│   - 高度なメトリクス分析                                     │
│   - 履歴トレンド表示                                        │
├─────────────────────────────────────────────────────────────┤
│ 永続化:                                                     │
│ • grafana_data volume (/var/lib/grafana)                   │
│ • プロビジョニング (./grafana/provisioning)                  │
│ • データソース自動設定 (UID: prometheus)                     │
└─────────────────────────────────────────────────────────────┘
```

### 3. **Node Exporter** (ホストシステム監視)
```
┌─────────────────────────────────────────────────────────────┐
│                  Node Exporter :9100                       │
├─────────────────────────────────────────────────────────────┤
│ 機能:                                                       │
│ ✓ ホストシステムメトリクス収集                                │
│ ✓ ハードウェア情報取得                                       │
│ ✓ ファイルシステム監視                                       │
│ ✓ ネットワークインターフェース監視                            │
├─────────────────────────────────────────────────────────────┤
│ 収集メトリクス:                                             │
│ • CPU使用率・ロードアベレージ                                │
│ • メモリ使用量・スワップ                                     │
│ • ディスク使用量・I/O統計                                    │
│ • ネットワーク送受信バイト数                                 │
│ • ファイルシステム情報                                       │
│ • プロセス統計                                              │
├─────────────────────────────────────────────────────────────┤
│ ホストマウント:                                             │
│ • /proc → /host/proc (プロセス情報)                         │
│ • /sys → /host/sys (システム情報)                           │
│ • / → /rootfs (ルートファイルシステム)                       │
└─────────────────────────────────────────────────────────────┘
```

### 4. **cAdvisor** (コンテナ監視)
```
┌─────────────────────────────────────────────────────────────┐
│                    cAdvisor :8080                          │
├─────────────────────────────────────────────────────────────┤
│ 機能:                                                       │
│ ✓ Dockerコンテナリソース監視                                 │
│ ✓ リアルタイムパフォーマンス分析                             │
│ ✓ コンテナライフサイクル追跡                                 │
│ ✓ ネットワーク・ストレージ使用量                             │
├─────────────────────────────────────────────────────────────┤
│ 監視項目:                                                   │
│ • コンテナCPU使用率                                         │
│ • コンテナメモリ使用量・制限                                 │
│ • ネットワークI/O統計                                       │
│ • ファイルシステムI/O                                       │
│ • コンテナ起動・停止イベント                                 │
├─────────────────────────────────────────────────────────────┤
│ 特殊設定:                                                   │
│ • privileged: true (システムアクセス)                       │
│ • /dev/kmsg デバイスアクセス                                │
│ • Docker socket マウント                                    │
│ • ホストファイルシステムアクセス                             │
└─────────────────────────────────────────────────────────────┘
```

### 5. **Alertmanager** (アラート管理)
```
┌─────────────────────────────────────────────────────────────┐
│                  Alertmanager :9093                        │
├─────────────────────────────────────────────────────────────┤
│ 機能:                                                       │
│ ✓ アラート受信・処理                                        │
│ ✓ 通知ルーティング                                          │
│ ✓ アラートグループ化                                        │
│ ✓ 抑制・サイレンス管理                                       │
├─────────────────────────────────────────────────────────────┤
│ アラートルール:                                             │
│ 1. 高CPU使用率アラート                                      │
│    • しきい値: >80%                                         │
│    • 持続時間: 5分間                                        │
│    • 重要度: warning                                        │
│                                                             │
│ 2. 高メモリ使用率アラート                                    │
│    • しきい値: >85%                                         │
│    • 持続時間: 5分間                                        │
│    • 重要度: warning                                        │
│                                                             │
│ 3. ディスク容量不足アラート                                  │
│    • しきい値: >90%                                         │
│    • 持続時間: 1分間                                        │
│    • 重要度: critical                                       │
│                                                             │
│ 4. サービス停止アラート                                      │
│    • 条件: up == 0                                          │
│    • 持続時間: 1分間                                        │
│    • 重要度: critical                                       │
├─────────────────────────────────────────────────────────────┤
│ 永続化:                                                     │
│ • alertmanager_data volume                                  │
│ • 設定ファイル (./alertmanager:/etc/alertmanager)           │
└─────────────────────────────────────────────────────────────┘
```

## 🌐 ネットワーク構成

```
┌─────────────────────────────────────────────────────────────┐
│              Docker Bridge Network: monitoring             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  prometheus ←──────→ node-exporter                         │
│      ↑ ↓                    ↑                              │
│      │ └─────────────────────┼─────────→ grafana           │
│      │                      │               ↑              │
│      │ ←─────────────────────┼───────────────┘              │
│      │                      │                              │
│      │ ←─────────────────────┼─────────→ cadvisor          │
│      │                      │                              │
│      │ ←─────────────────────┼─────────→ alertmanager      │
│      │                      │                              │
│      └──────────────────────────────────────────────────────┤
│                                                             │
│ ポートマッピング (ホスト:コンテナ):                          │
│ • 9090:9090  → Prometheus Web UI                           │
│ • 3000:3000  → Grafana Dashboard                           │
│ • 9100:9100  → Node Exporter Metrics                       │
│ • 8080:8080  → cAdvisor Web UI                             │
│ • 9093:9093  → Alertmanager Web UI                         │
└─────────────────────────────────────────────────────────────┘
```

## 💾 データ永続化戦略

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Volumes                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  prometheus_data:                                           │
│  • TSDB時系列データベース                                    │
│  • 200時間のメトリクス保持                                   │
│  • 高性能アクセス最適化                                      │
│                                                             │
│  grafana_data:                                              │
│  • ダッシュボード設定                                        │
│  • ユーザー設定・セッション                                  │
│  • プラグイン・テーマ                                        │
│                                                             │
│  alertmanager_data:                                         │
│  • アラート履歴                                             │
│  • サイレンス設定                                           │
│  • 通知ステータス                                           │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                    Bind Mounts                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ./prometheus → /etc/prometheus:                            │
│  • prometheus.yml (スクレイプ設定)                          │
│  • alert-rules.yml (アラートルール)                         │
│                                                             │
│  ./grafana/provisioning → /etc/grafana/provisioning:       │
│  • datasources/ (データソース自動設定)                       │
│  • dashboards/ (ダッシュボード自動配置)                      │
│                                                             │
│  ./alertmanager → /etc/alertmanager:                       │
│  • alertmanager.yml (ルーティング設定)                      │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 デプロイメント手順

```bash
# 1. 環境準備
git clone <repository>
cd monitoring-lab

# 2. 設定確認
cat docker-compose.yml
cat prometheus/prometheus.yml
cat grafana/provisioning/datasources/prometheus.yml

# 3. サービス起動
docker-compose up -d

# 4. 起動確認
docker-compose ps
./health-check.sh

# 5. アクセス確認
open http://localhost:3000  # Grafana
open http://localhost:9090  # Prometheus
open http://localhost:9100  # Node Exporter
open http://localhost:8080  # cAdvisor
open http://localhost:9093  # Alertmanager
```

## 🔍 トラブルシューティング

### よくある問題と解決方法

1. **ダッシュボードにデータが表示されない**
   ```bash
   # データソース設定確認
   curl http://localhost:9090/api/v1/query?query=up
   
   # Grafana設定確認
   docker logs grafana
   ```

2. **メトリクス収集エラー**
   ```bash
   # Prometheusターゲット確認
   curl http://localhost:9090/targets
   
   # 各エクスポーター確認
   curl http://localhost:9100/metrics
   curl http://localhost:8080/metrics
   ```

3. **アラートが動作しない**
   ```bash
   # アラートルール確認
   curl http://localhost:9090/api/v1/rules
   
   # Alertmanager確認
   curl http://localhost:9093/api/v1/alerts
   ```

この構成により、包括的なDocker環境監視システムが実現され、リアルタイムでのシステム状況把握とプロアクティブなアラート管理が可能になります。
