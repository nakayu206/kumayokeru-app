# Android リリース手順チェックリスト

## 1. リリース用キーストアの生成

```bash
keytool -genkey -v \
  -keystore kumayokeru-release.jks \
  -alias kumayokeru \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> キーストアファイルは**絶対にGitにコミットしない**こと。安全な場所に保管する。

## 2. key.properties の作成

`android/key.properties`(`.gitignore`で除外済み)を作成し、以下を記入:

```
storePassword=<キーストアのパスワード>
keyPassword=<キーのパスワード>
keyAlias=kumayokeru
storeFile=<キーストアファイルの絶対パス>
```

`android/app/build.gradle.kts`の`buildTypes.release`は現状デバッグ鍵で署名する設定になっている
(`signingConfig = signingConfigs.getByName("debug")`)。本番リリース前に上記key.propertiesを
読み込む`signingConfigs.create("release")`に差し替えること。

## 3. AWS Cognito / API Gatewayの本番エンドポイント確認(Phase2以降)

FirebaseのようなGoogleサービス側の`google-services.json`は不要。代わりに
[環境構築手順.md](環境構築手順.md)セクション10の手順でAWS Amplifyの
`amplifyconfiguration.dart`をprod環境向けに再生成し、`lib/`に配置されているか確認する。

## 4. リリースビルドの確認

```bash
flutter build apk --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

## 5. ストア掲載情報のレビュー

- [ ] 「クマを撃退する」等の誇大な効能表示がないか、ストア掲載文言をレビュー([全体設計書.md](全体設計書.md)セクション2のコンセプトに反していないか)
- [ ] バックグラウンド音声・位置情報のパーミッション説明文をストア掲載情報に明記
- [ ] プライバシーポリシー・利用規約のURLを掲載

## 6. Google Play Consoleへの提出

1. [Google Play Console](https://play.google.com/console) でアプリを作成
2. Application ID: `com.kumayokeru.app`
3. `build/app/outputs/bundle/prodRelease/app-prod-release.aab` をアップロード

## 関連

- [環境構築手順.md](環境構築手順.md)
- [全体設計書.md](全体設計書.md) セクション19(Androidリリースチェックリスト)、21(リリース・運用計画)
- GitHub Issue #4(Phase 3: 正式リリース)
