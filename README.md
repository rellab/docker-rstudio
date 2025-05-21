# RStudio Server Docker Environment

このリポジトリは、**ローカルまたはクラウド環境で簡単に RStudio Server を動かすための Docker イメージ** を提供します。 
**amd64 / arm64 (Apple Silicon) 対応** のマルチアーキテクチャビルドが可能で、Rの代表的パッケージ **tidyverse** と **日本語フォント** をプリインストールしています。

このイメージは **GitHub Container Registry (GHCR)** にプッシュすることを前提としています。

---

## 📂 構成ファイル

| ファイル名        | 説明                                                        |
|-------------------|-------------------------------------------------------------|
| Dockerfile        | RStudio Server イメージ定義。tidyverseおよびビルド依存ライブラリ、日本語フォントを含む |
| entrypoint.sh     | 起動時にパスワード設定・sudo権限付与などの初期設定を行うスクリプト |
| Makefile          | **GHCR用のマルチアーキテクチャビルド**定義 |

---

## 🚀 利用方法

### 1. GitHub Container Registry (GHCR) ログイン

あらかじめ [GitHub Personal Access Token](https://github.com/settings/tokens) を取得し、以下の環境変数を設定します。

```bash
export GITHUB_USER=your-username
export GITHUB_TOKEN=your-token
```

ログイン:

```bash
make login
```

### 2. イメージのビルドとプッシュ

以下のコマンドで **マルチアーキテクチャ (amd64, arm64) 対応イメージをビルドし、GHCRへプッシュ** します。

```bash
make build
```

ビルドされるイメージ名は以下の形式です。

```
ghcr.io/rellab/docker-rstudio:latest
```

### 3. コンテナ起動

```bash
docker run -d \
  -p 8787:8787 \
  -e RSTUDIO_PASSWORD=yourpassword \
  -v $(pwd)/work:/home/rstudio \
  --name rstudio-server \
  ghcr.io/rellab/docker-rstudio:latest
```

**初期ユーザ・パスワード**
- ユーザ名: `rstudio`
- パスワード: 環境変数 `RSTUDIO_PASSWORD` で設定 (デフォルト: `passwd`)

**RStudioへのアクセス**

[http://localhost:8787](http://localhost:8787)


### 4. 開発用パッケージ・ライブラリ

本イメージには、以下のシステムライブラリとフォントがインストール済みです。

#### 開発用ライブラリ

- libcurl4-openssl-dev
- libssl-dev
- zlib1g-dev
- libssh2-1-dev
- libopenblas0
- libopenblas-dev
- psmisc
- libapparmor1
- libxml2-dev
- libgmp3-dev
- libmpfr-dev
- libclang-dev

#### 日本語フォント

- fonts-noto-cjk

これにより、**tidyverseを含む多くのRパッケージがそのまま利用可能**で、
**ggplot2, rmarkdown, Shiny などでの日本語表示もサポート**されています。

### 5. クリーンアップ

```bash
make clean
```

---

## ⚙️ 環境変数一覧

| 変数名              | 説明                                         | デフォルト値 |
|--------------------|--------------------------------------------|------------:|
| RSTUDIO_USER       | RStudio のユーザ名                           | `rstudio`   |
| RSTUDIO_PASSWORD   | ログインパスワード                           |  `passwd`   |
| RSTUDIO_GRANT_SUDO | sudo権限付与設定 (`yes` / `nopass` / 空)       |  `nopass`   |
| RSTUDIO_PORT       | RStudio Server のポート番号                  |      `8787` |
| TZ                 | タイムゾーン                                 | `Asia/Tokyo`|

---

## ✅ /home/rstudio ディレクトリについて

RStudio Server はデフォルトで **rstudio ユーザのホームディレクトリを `/home/rstudio`** として動作します。

**/work など他のディレクトリをホームにすることもできますが、セッション管理や設定ファイルの互換性の観点から、標準の `/home/rstudio` を利用することを推奨**します。

そのため、データ永続化を行う場合は以下のように **ホストディレクトリと `/home/rstudio` を bind mount** する方法が最も安全です。

```bash
docker run -d \
  -p 8787:8787 \
  -e RSTUDIO_PASSWORD=yourpassword \
  -v $(pwd)/work:/home/rstudio \
  ghcr.io/rellab/docker-rstudio:latest
```

ホスト側では `/work` にデータを置きつつ、コンテナ内では `/home/rstudio` として扱われます。

## Docker-compose

```
services:
  ssh:
    image: ghcr.io/rellab/docker-ssh-nogpu:latest
    environment:
      - SSH_USER=youruser
      - SSH_PUBLIC_KEY=ssh-rsa AAAA...
    ports:
      - "0:22"
    networks:
      - internal

  rstudio:
    image: ghcr.io/rellab/docker-rstudio:latest
    environment:
      - RSTUDIO_PASSWORD=rstudio
      - RSTUDIO_BIND=0.0.0.0
    volumes:
      - ./work:/home/rstudio
    networks:
      - internal

networks:
  internal:
    driver: bridge
```
---

## 🔧 RStudio Server 簡易操作スクリプト

ローカル開発用途で便利な **RStudio Server コンテナ操作スクリプト** を以下に示します。

**任意のディレクトリに `control.sh` という名前で保存し、実行権限を付与してください。**

```bash
#!/bin/bash

PNAME=$(basename "$PWD")
CNAME="rstudio-$PNAME"
PORT=$((8700 + $(echo "$PNAME" | cksum | awk '{print $1 % 100}')))

case "$1" in
  start)
    mkdir -p ./work
    echo "Starting $CNAME on port $PORT"
    docker run -d \
      -p "$PORT:8787" \
      -e RSTUDIO_PASSWORD="$PNAME" \
      -v "$PWD/work":/home/rstudio \
      --name "$CNAME" \
      ghcr.io/rellab/docker-rstudio:latest
    echo "Access: http://localhost:$PORT"
    ;;
  stop)
    echo "Stopping $CNAME"
    docker stop "$CNAME"
    ;;
  remove)
    echo "Removing $CNAME"
    docker rm "$CNAME"
    ;;
  restart)
    echo "Restarting $CNAME"
    docker stop "$CNAME"
    docker rm "$CNAME"
    mkdir -p ./work
    docker run -d \
      -p "$PORT:8787" \
      -e RSTUDIO_PASSWORD="$PNAME" \
      -v "$PWD/work":/home/rstudio \
      --name "$CNAME" \
      ghcr.io/rellab/docker-rstudio:latest
    echo "Restarted $CNAME on port $PORT"
    ;;
  status)
    docker ps -a -f name="^/${CNAME}$"
    ;;
  list)
    echo "RStudio containers:"
    docker ps -a --filter "name=rstudio-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    ;;
  *)
    echo "Usage: $0 {start|stop|remove|restart|status|list}"
    ;;
esac
```

### 使用方法

```bash
chmod +x control.sh
./control.sh start   # コンテナ起動
./control.sh stop    # コンテナ停止
./control.sh remove  # コンテナ削除
./control.sh restart # コンテナ再起動
./control.sh status  # コンテナの状態確認
./control.sh list    # rstudio- から始まる全コンテナ一覧
```

**コンテナ名・ポートは現在のディレクトリ名から自動生成** されます。
例: `myproject` というディレクトリで実行すると

- コンテナ名 → `rstudio-myproject`
- ポート → `8700〜8799` の中で自動計算

パスワードも **ディレクトリ名と同じ** に設定されます。

---

## 📄 ライセンス

MIT License または rocker/rstudio のライセンスに従ってご利用ください。

---

## 📝 拡張

- [SSL対応](SSL.md)

## 今後の拡張

- 複数ユーザ対応

