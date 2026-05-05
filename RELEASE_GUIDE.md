# Google Play Store リリースガイド

## 前提条件

- Flutter SDK がインストールされていること
- Java Development Kit (JDK) がインストールされていること
- Google Play Console アカウント（デベロッパー登録料 $25 が必要）

## 手順1: 署名キーの作成

### 1.1 キーストアフォルダを作成

```bash
cd C:\work\python\generated_apps\kokoro_compass
mkdir android\keystore
```

### 1.2 署名キーを生成

```bash
keytool -genkey -v -keystore android/keystore/kokorocompass-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kokorocompass
```

プロンプトに従って以下を入力：
- キーストアパスワード（安全なパスワードを設定）
- 名前、組織名、都市、国など

**重要**: キーストアファイルとパスワードは絶対に紛失しないでください。アプリの更新に必要です。

### 1.3 key.properties を設定

```bash
copy android\key.properties.template android\key.properties
```

`android/key.properties` を編集して実際の値を入力：

```properties
storePassword=あなたのストアパスワード
keyPassword=あなたのキーパスワード
keyAlias=kokorocompass
storeFile=../keystore/kokorocompass-release-key.jks
```

## 手順2: アプリアイコンの準備

以下のサイズのアイコンを用意してください：

- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

または、`flutter_launcher_icons` パッケージを使用：

```yaml
# pubspec.yaml に追加
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
```

## 手順3: リリースビルドの作成

### 3.1 依存関係を取得

```bash
flutter pub get
```

### 3.2 AAB（Android App Bundle）をビルド

```bash
flutter build appbundle --release
```

生成されるファイル：
`build/app/outputs/bundle/release/app-release.aab`

## 手順4: Google Play Console での公開

### 4.1 アプリを作成

1. [Google Play Console](https://play.google.com/console) にログイン
2. 「アプリを作成」をクリック
3. アプリ情報を入力：
   - アプリ名: こころコンパス
   - デフォルト言語: 日本語
   - アプリまたはゲーム: アプリ
   - 無料または有料: 無料

### 4.2 ストア掲載情報を設定

- **簡単な説明** (80文字以内):
  ```
  感謝日記、瞑想、呼吸法、睡眠記録など、毎日の心の健康をサポートするウェルネスアプリ
  ```

- **詳細な説明** (4000文字以内):
  ```
  こころコンパスは、あなたの心の健康を毎日サポートするウェルネスアプリです。

  主な機能：
  - 感謝日記: 日々の感謝を記録し、ポジティブな思考を育てます
  - 幸福度トラッキング: 気分を記録し、パターンを発見します
  - 瞑想ガイド: マインドフルネス瞑想で心を落ち着けます
  - 呼吸法: 4-4-4-2呼吸法でリラックス
  - 睡眠記録: 睡眠の質を追跡します
  - 今日の目標: 毎日の意図と目標を設定
  - リラクゼーションサウンド: 9種類の環境音
  - ジャーナリングプロンプト: 心の整理をサポート
  - ムードカレンダー: 気分の推移を視覚化
  - インサイト: AIがあなたのパターンを分析
  - 週間レポート: 一週間の振り返り
  - 達成バッジ: モチベーションを維持

  プライバシーを重視し、すべてのデータはデバイス内にのみ保存されます。
  ```

### 4.3 スクリーンショットを用意

必要なスクリーンショット：
- 携帯電話: 2〜8枚
- 7インチタブレット: 最大8枚
- 10インチタブレット: 最大8枚

推奨サイズ：1080 x 1920 ピクセル（9:16）

### 4.4 アプリのコンテンツ評価

コンテンツ評価質問票に回答してください。
このアプリは一般的に「全年齢対象」に該当します。

### 4.5 プライバシーポリシー

プライバシーポリシーURLを設定（PRIVACY_POLICY.md の内容をウェブページとして公開）

### 4.6 AABをアップロード

1. 「リリース」>「本番」に移動
2. 「新しいリリースを作成」
3. `app-release.aab` をアップロード
4. リリースノートを入力
5. 審査に提出

## 手順5: 審査と公開

- Google Play の審査には通常数日かかります
- 問題があれば修正して再提出してください
- 承認されると、Play Store に公開されます

## トラブルシューティング

### ビルドエラーが発生した場合

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### 署名エラーが発生した場合

- `key.properties` のパスとパスワードを確認
- キーストアファイルが存在することを確認

## 重要な注意事項

1. **キーストアファイルを安全に保管**: 紛失するとアプリを更新できなくなります
2. **key.properties をバージョン管理に含めない**: .gitignore に追加済み
3. **プライバシーポリシーを公開**: ウェブページとして公開が必要
4. **アプリIDの変更禁止**: `com.kokorocompass.app` は公開後に変更できません
