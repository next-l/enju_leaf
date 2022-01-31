# Next-L Enju Leaf
[![Ruby on Rails CI](https://github.com/next-l/enju_leaf/actions/workflows/rubyonrails.yml/badge.svg?branch=docker-1.3)](https://github.com/next-l/enju_leaf/actions/workflows/rubyonrails.yml)
[![Test Coverage](https://api.codeclimate.com/v1/badges/94c718eb65bff900f95f/test_coverage)](https://codeclimate.com/github/next-l/enju_leaf/test_coverage)

Next-L Enju Leaf は、[Project Next-L](https://www.next-l.jp) で開発している図書館管理システムです。

Next-L Enju Leaf is an integrated library system developed by [Project
Next-L](https://www.next-l.jp).

## Project Next-L とは (What is Project Next-L?)
[Project Next-L](https://www.next-l.jp)
とは、日本の図書館関係者有志の手で新しい図書館管理システムを作り上げるプロジェクトです。

[Project Next-L](https://www.next-l.jp) is a project to build a new integrated
library system maintained by Japanese volunteers interested in libraries.

## 動作デモ (Demonstration)
* https://enju.next-l.jp


## マニュアル (Manual)
* https://next-l.github.io/manual/


## インストール (Install)

```sh
$ git clone -b docker-1.3 https://github.com/next-l/enju_leaf.git
$ cd enju_leaf
$ cp .env.template .env
$ docker compose run --rm web rake db:create
$ docker compose run --rm web rake db:migrate
$ docker compose run --rm web rake enju_leaf:setup
$ docker compose run --rm web rake db:seed
$ docker compose up
```

アプリケーションは http://localhost:3000 で動作します。初期ユーザ名は`enjuadmin`、パスワードは`adminpassword`です。

## 関連するプロジェクト (Related projects)
* [Next-L Enju Root](https://github.com/next-l/enju_root)
* [Next-L Enju Flower](https://github.com/next-l/enju_flower)


## 製作者・貢献者 (Authors and contributors)
* [TANABE, Kosuke](https://github.com/nabeta) ([@nabeta](https://twitter.com/nabeta))
* [Project Next-L](https://www.next-l.jp) ([@ProjectNextL](https://twitter.com/ProjectNextL))
