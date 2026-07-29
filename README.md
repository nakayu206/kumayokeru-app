# クマヨケール ― 登山のお守り

登山・ハイキングをする人が、クマとの不意の遭遇による事故を減らし、安心して山に入れる状態をつくるアプリ。
「クマを撃退する」のではなく、「気配を伝えて、すれ違う」がコンセプト。

## ドキュメント

- [全体設計書](docs/全体設計書.md) — プロジェクト目標・機能・アーキテクチャ・データ設計・ロードマップ
- [デザイントークン](docs/デザイントークン.md) — カラー・スペーシング・サイズ等のUI定数
- [コード規約](docs/コード規約.md) — 命名規則・アーキテクチャ方針・テスト規約
- [環境とブランチ運用](docs/環境とブランチ運用.md) — Flavor・GitHub Flow + タグリリース
- [環境構築手順](docs/環境構築手順.md) — 新規セットアップ手順(Flutter/Android/iOS/AWS)
- [テスト方針](docs/テスト方針.md)
- [Androidリリースチェックリスト](docs/android_release_checklist.md)
- [iOS Flavorセットアップ(Mac作業待ち)](ios/FLAVOR_SETUP.md)

## クイックスタート

```bash
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

詳細は[環境構築手順.md](docs/環境構築手順.md)を参照。

## 開発状況

GitHub Issue([一覧](https://github.com/nakayu206/kumayokeru-app/issues))でロードマップ(Phase 0〜4)と
画面別のUI/Logicタスクを管理しています。
