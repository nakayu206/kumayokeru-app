# iOS Flavor セットアップ(未完了・Mac作業が必要)

> `ios/Flutter/*.xcconfig` はこのリポジトリ内(Windows)で作成済み。
> ただし **Xcodeの Build Configuration / Scheme の追加は Mac + Xcode がないと行えない** ため未着手。
> tekushare-appでは `xcodeproj` Ruby gemのスクリプトで自動生成した(本ファイル末尾に手順を記録)。

## 現状(このリポジトリで完了している部分)

- `ios/Flutter/Dev.xcconfig` / `Stg.xcconfig` / `Prod.xcconfig`
  → `BUNDLE_ID_SUFFIX` / `BUNDLE_DISPLAY_NAME` を定義済み
- `ios/Flutter/<Debug|Release|Profile>-<dev|stg|prod>.xcconfig`(9ファイル)
  → 上記2つ + 標準の`Debug.xcconfig`/`Release.xcconfig`をincludeする形で作成済み
- `android/app/build.gradle.kts` のFlavor設定(dev/stg/prod)は完了済み

## Macで行う必要がある作業

### 1. Build Configuration の追加(プロジェクト・Runner・RunnerTests 各ターゲット)

`Runner.xcodeproj` に対して、既存の `Debug` / `Release` / `Profile` を複製し、
以下の9つのConfigurationを追加する。

- `Debug-dev` / `Release-dev` / `Profile-dev`
- `Debug-stg` / `Release-stg` / `Profile-stg`
- `Debug-prod` / `Release-prod` / `Profile-prod`

`Runner`ターゲットの各Configurationで:
- Configuration File を対応する `ios/Flutter/<Name>.xcconfig` に設定
- `PRODUCT_BUNDLE_IDENTIFIER` を `com.kumayokeru.app$(BUNDLE_ID_SUFFIX)` に上書き

### 2. Scheme の追加

`dev` / `stg` / `prod` の共有Scheme(Shared)を作成し、それぞれ対応する
`Debug-<flavor>` / `Release-<flavor>` / `Profile-<flavor>` のConfigurationを紐付ける。
`flutter run --flavor <dev|stg|prod>` はこのScheme名をそのまま探しにいく。

### 3. Podfile

`pod install` 実行後に生成される `ios/Podfile` の `project 'Runner', {...}` に、
9つのConfigurationすべてを `:debug` / `:release` にマッピングする(CocoaPodsが
flavor別のxcconfigを生成するために必須)。

### 4. Info.plist(このリポジトリで対応済み)

`ios/Runner/Info.plist` に位置情報権限の説明文・`UIBackgroundModes: audio`・
`CFBundleDisplayName` の `$(BUNDLE_DISPLAY_NAME)` 参照化まで追加済み。
ただし `BUNDLE_DISPLAY_NAME` はDev/Stg/Prod.xcconfig側でのみ定義されているため、
上記1のBuild Configuration作成が完了するまでは、Xcode標準のDebug/Release/Profileで
ビルドした場合にアプリ名が空になる(Configuration作成後は正しく反映される)。

### 5. 動作確認

```bash
cd ios && pod install
flutter run --flavor dev  -t lib/main_dev.dart
flutter run --flavor stg  -t lib/main_stg.dart
flutter run --flavor prod -t lib/main_prod.dart --release
```

---

## Build Configuration / Scheme をスクリプトで作る場合(tekushare-app実績あり)

Xcode GUIで9個のConfigurationと3個のSchemeを手作業で作るのはミスが起きやすいため、
`xcodeproj` Ruby gemを使って再現する方法がある。

```bash
gem install xcodeproj
```

```ruby
require 'xcodeproj'
project = Xcodeproj::Project.open('ios/Runner.xcodeproj')

flavors = %w[dev stg prod]
bases   = %w[Debug Release Profile]

# プロジェクトレベル / Runnerターゲット / RunnerTestsターゲットそれぞれの
# XCConfigurationListに対して、既存のDebug/Release/Profileを複製し
# 新しい名前(例: "Debug-dev")を付ける。Runnerターゲット分だけ
# base_configuration_referenceを対応するios/Flutter/<name>.xcconfigに差し替え、
# PRODUCT_BUNDLE_IDENTIFIERを 'com.kumayokeru.app$(BUNDLE_ID_SUFFIX)' に上書きする。
```

Schemeは既存の`Runner.xcscheme`を複製し、`buildConfiguration="Debug"`等の属性を
`buildConfiguration="Debug-dev"`のように置換するだけで作れる(XMLなのでテキスト置換で十分)。

複製後は `cd ios && pod install` を必ず実行すること(flavor分の
`Pods-Runner.<config>.xcconfig`が生成され、各xcconfigからincludeされるため)。
