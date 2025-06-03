# 🔧 Monitoring Lab - Hello World Tutorial

MacBook Pro M3でPrometheus + Grafanaの監視環境を構築するチュートリアル

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