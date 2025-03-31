# RStudio Server + Traefik HTTPS 環境構築手順

このドキュメントでは、**Traefik を用いて RStudio Server を HTTPS 化し、安全に外部公開する方法** をまとめています。

---

## 📄 構成ファイル

| ファイル名             | 説明                                               |
|----------------------|----------------------------------------------------|
| docker-compose.yml   | RStudio Server と Traefik のサービス定義             |
| ./letsencrypt/acme.json | Let's Encrypt の証明書・秘密鍵情報保存ファイル |
| ./work               | RStudio Server のホームディレクトリ (データ永続化) |

---

## 🚀 セットアップ手順

### 1. 必要なフォルダとファイルの準備

```bash
mkdir -p letsencrypt work
chmod 600 letsencrypt/acme.json
```

`acme.json` は Traefik が Let's Encrypt 証明書を保存するファイルです。
**必ず600権限にしてください。**

```bash
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json
```

### 2. docker-compose.yml の確認

以下のような構成になっています。

```yaml
services:
  traefik:
    image: traefik:v2.10
    command:
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --certificatesresolvers.myresolver.acme.httpchallenge=true
      - --certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web
      - --certificatesresolvers.myresolver.acme.email=you@example.com
      - --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt
    networks:
      - web

  rstudio:
    image: ghcr.io/rellab/docker-rstudio:latest
    environment:
      - RSTUDIO_PASSWORD=yourpassword
    volumes:
      - ./work:/home/rstudio
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.rstudio.rule=Host(`rstudio.example.com`)"
      - "traefik.http.routers.rstudio.entrypoints=websecure"
      - "traefik.http.routers.rstudio.tls.certresolver=myresolver"
      - "traefik.http.services.rstudio.loadbalancer.server.port=8787"
    networks:
      - web

networks:
  web:
    external: false
```

**ご自身のドメイン名 (`rstudio.example.com`) とメールアドレス (`you@example.com`) を必ず変更してください。**

### 3. コンテナの起動

```bash
docker compose up -d
```

起動後、初回アクセス時に **Let's Encrypt証明書が自動取得** されます。

---

## 🔐 acme.json について

`./letsencrypt/acme.json` は **Traefik が取得した証明書と秘密鍵を保存するファイル** です。

このファイルは:
- **再起動後も証明書情報を保持**
- **証明書の有効期限 (90日) が近づくと自動更新**

のために必須です。

**このファイルは秘密鍵を含むため、外部公開しないでください。**

---

## 🌐 アクセス

ブラウザで以下にアクセス

```
https://rstudio.example.com
```

ログイン情報:
- ユーザ名: `rstudio`
- パスワード: 環境変数 `RSTUDIO_PASSWORD` で指定したもの

---

## ⚙️ 補足

- **ポート80, 443 をグローバルIPで開放**しておく必要があります。
- ドメインのDNS設定で `rstudio.example.com` がこのサーバのIPに向くよう設定してください。

