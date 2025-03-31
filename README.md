# RStudio Server Docker Environment

このリポジトリは、**ローカルまたはクラウド環境で簡単に RStudio Server を動かすための Docker イメージ** を提供します。 
**amd64 / arm64 (Apple Silicon) 対応** のマルチアーキテクチャビルドが可能で、Rの代表的パッケージ **tidyverse** をプリインストールしています。

このイメージは **GitHub Container Registry (GHCR)** にプッシュすることを前提としています。

---

## 📂 構成ファイル

| ファイル名        | 説明                                                        |
|-------------------|-------------------------------------------------------------|
| Dockerfile        | RStudio Server イメージ定義。tidyverseおよびビルド依存ライブラリを含む |
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

本イメージには、以下のシステムライブラリがインストール済みです。

- libcurl4-openssl-dev
- libssl-dev
- zlib1g-dev
- libssh2-1-dev
- libopenblas-base
- libopenblas-dev
- psmisc
- libapparmor1
- libxml2-dev
- libgmp3-dev
- libmpfr-dev
- libclang-dev

これにより、**tidyverseを含む多くのRパッケージがそのまま利用可能**です。

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

---

## 📄 ライセンス

MIT License または rocker/rstudio のライセンスに従ってご利用ください。

---

## 📝 今後の拡張 (案)

- 日本語フォントの追加
- 複数ユーザ対応
- SSL対応

必要に応じてご相談ください。

