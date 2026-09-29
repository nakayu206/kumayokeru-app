# CLAUDE.md

このリポジトリで作業するAIエージェント（Claude Code）向けのルール集約ファイル。個別ドキュメントに散らばる決定事項ではなく、**作業の進め方そのものに関するルール**をここにまとめる。姉妹リポジトリ（kumayokeru-backend、kosodate-hitoiki／kosodate-hitoiki-backend、burari-date、tekushare-app）と運用方針を揃えることを前提とする。

## このリポジトリについて

クマヨケール ― 登山中のクマとの不意の遭遇事故を減らすアプリ（Flutter）。バックエンドは別リポジトリ [kumayokeru-backend](https://github.com/nakayu206/kumayokeru-backend)。

## ドキュメントの優先順位

| ドキュメント | 内容 |
|---|---|
| [全体設計書](docs/全体設計書.md) | プロジェクト目標・機能・アーキテクチャ・データ設計・ロードマップ |
| [デザイントークン](docs/デザイントークン.md) | カラー・スペーシング・サイズ等のUI定数 |
| [コード規約](docs/コード規約.md) | 命名規則・アーキテクチャ方針・テスト規約（**必読**） |
| [環境とブランチ運用](docs/環境とブランチ運用.md) | Flavor（dev/stg/prod）・GitHub Flow + タグリリース |
| [環境構築手順](docs/環境構築手順.md) | 新規セットアップ手順（Flutter/Android/iOS/AWS） |
| [テスト方針](docs/テスト方針.md) | 単体・結合テストの方針と実行コマンド |
| [Androidリリースチェックリスト](docs/android_release_checklist.md) | リリース前確認事項 |

コードを書く前に必ず[コード規約](docs/コード規約.md)を確認する。命名規則・importの順序・エラー表示の方針（バリデーションは画面内`ErrorText`、通信・認証エラーは`showErrorDialog()`）・非同期処理（`async/await`、`try/catch`必須、握りつぶし禁止）はこの規約に従う。

## ブランチ・PRの運用: GitHub Flow + タグリリース

**環境ごとの長命ブランチ（dev/stg/prodブランチ）は作らない。** 環境の切り替えはGitブランチではなくFlavor（`lib/main_dev.dart`/`main_stg.dart`/`main_prod.dart`）で行う（[環境とブランチ運用](docs/環境とブランチ運用.md)参照）。

```text
main                    ← これ1本
  ├─ feature/xxx        ← 機能開発（短命）
  └─ fix/xxx             ← バグ修正（短命）
```

- `main`へのpushで自動的にstgへデプロイされる（`deploy-stg.yml`）。`v*.*.*`タグのpushでprodへデプロイされる（`deploy-prod.yml`）。
- 作業は`main`から`feature/xxx`・`fix/xxx`を切り、PR経由で`main`へマージする。`main`へ直接pushしない。
- 全てのPRはレビュー必須（最低1名の承認）。CIで`test`/`analyze`が自動実行される。
- PRと同じタイミングで対応するテストを必ず作成する（[コード規約](docs/コード規約.md)・[テスト方針](docs/テスト方針.md)）。バックグラウンド音声・位置情報などOS依存処理を含むPRは実機テスト結果を添付する。

## コミット・PRメッセージ

- 日本語で、変更の意図（なぜ）が分かるように書く。
- コミットメッセージ・PR説明の末尾に付ける attribution（Co-Authored-By等）は、呼び出し元（Claude Codeのシステム設定）の指示に従う。本ファイルでは固定しない。

## セットアップ・実行

```bash
flutter pub get

# 開発中の動作確認
flutter run --flavor dev -t lib/main_dev.dart

# テスト
flutter test
flutter test integration_test/   # 結合テスト（実機/エミュレータ必要）
```

新規セットアップの詳細は[環境構築手順](docs/環境構築手順.md)を参照。iOSのFlavor設定はMac作業待ちのため[ios/FLAVOR_SETUP.md](ios/FLAVOR_SETUP.md)を確認する。
