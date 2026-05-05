# Apple App Store リリースガイド

## 前提条件

- macOS搭載のMac（Xcodeが必要）
- Xcode（最新版推奨）
- Flutter SDK
- Apple Developer Program メンバーシップ（年間 $99 / ¥12,980）

**注意**: iOSアプリのビルドとApp Store公開にはMacが必須です。

## 手順1: Apple Developer Program への登録

1. [Apple Developer](https://developer.apple.com/programs/) にアクセス
2. 「Enroll」をクリック
3. Apple IDでサインイン
4. 個人または組織として登録
5. 年間メンバーシップ料金を支払い

## 手順2: App Store Connect でアプリを作成

### 2.1 App IDの登録

1. [Apple Developer Portal](https://developer.apple.com/account/) にログイン
2. 「Certificates, Identifiers & Profiles」を選択
3. 「Identifiers」>「+」をクリック
4. 「App IDs」を選択して続行
5. 以下の情報を入力：
   - Description: Kokoro Compass
   - Bundle ID: `com.kokorocompass.app` (Explicit)
6. 必要なCapabilitiesを選択（このアプリではデフォルトでOK）
7. 「Register」をクリック

### 2.2 App Store Connect でアプリを作成

1. [App Store Connect](https://appstoreconnect.apple.com/) にログイン
2. 「マイApp」>「+」>「新規App」
3. 以下の情報を入力：
   - プラットフォーム: iOS
   - 名前: こころコンパス
   - プライマリ言語: 日本語
   - バンドルID: com.kokorocompass.app
   - SKU: kokorocompass001
4. 「作成」をクリック

## 手順3: 証明書とプロビジョニングプロファイルの設定

### 3.1 自動署名（推奨）

Xcodeで自動署名を使用する場合：

1. Xcodeでプロジェクトを開く
   ```bash
   open ios/Runner.xcworkspace
   ```
2. 「Runner」プロジェクトを選択
3. 「Signing & Capabilities」タブ
4. 「Automatically manage signing」にチェック
5. Teamを選択（Apple Developer アカウント）

### 3.2 手動署名（オプション）

1. Apple Developer Portalで配布証明書を作成
2. プロビジョニングプロファイルを作成
3. Xcodeでダウンロードして設定

## 手順4: アプリアイコンの設定

必要なサイズ（全てPNG、透過なし）：

| サイズ | 用途 |
|--------|------|
| 20pt @2x (40x40) | iPhone通知 |
| 20pt @3x (60x60) | iPhone通知 |
| 29pt @2x (58x58) | iPhone設定 |
| 29pt @3x (87x87) | iPhone設定 |
| 40pt @2x (80x80) | iPhone Spotlight |
| 40pt @3x (120x120) | iPhone Spotlight |
| 60pt @2x (120x120) | iPhone App |
| 60pt @3x (180x180) | iPhone App |
| 1024pt (1024x1024) | App Store |

アイコンの配置先：
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`

または `flutter_launcher_icons` パッケージを使用：

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  ios: true
  image_path: "assets/icon/app_icon.png"
```

## 手順5: リリースビルドの作成

### 5.1 Flutterビルド

```bash
# 依存関係を取得
flutter pub get

# iOSリリースビルド
flutter build ios --release
```

### 5.2 Xcodeでアーカイブ

1. Xcodeでプロジェクトを開く
   ```bash
   open ios/Runner.xcworkspace
   ```

2. ビルドターゲットを設定
   - Product > Destination > Any iOS Device (arm64)

3. アーカイブを作成
   - Product > Archive

4. アーカイブ完了後、Organizerが開く

### 5.3 App Store Connect にアップロード

1. Organizerで作成したアーカイブを選択
2. 「Distribute App」をクリック
3. 「App Store Connect」を選択
4. 「Upload」を選択
5. オプションを確認して続行
6. アップロード完了を待つ

## 手順6: App Store Connect での設定

### 6.1 アプリ情報

- **カテゴリ**: ヘルスケア/フィットネス または ライフスタイル
- **コンテンツ配信権**: いいえ
- **年齢制限**: 4+

### 6.2 価格と配信地域

- **価格**: 無料
- **配信地域**: 日本（または全世界）

### 6.3 App Storeの掲載情報

**プロモーションテキスト** (170文字以内):
```
毎日の心の健康をサポート。感謝日記、瞑想、呼吸法、睡眠記録など、あなたのウェルネスを支える機能が充実。
```

**説明文** (4000文字以内):
```
こころコンパスは、あなたの心の健康を毎日サポートするウェルネスアプリです。

【主な機能】

■ 記録する
・感謝日記 - 日々の感謝を記録し、ポジティブな思考を育てます
・幸福度トラッキング - 気分を記録し、自分のパターンを発見
・睡眠記録 - 睡眠の質と時間を追跡
・今日の目標 - 毎日の意図と目標を設定

■ リラックス
・瞑想ガイド - マインドフルネス瞑想で心を落ち着ける
・呼吸法 - 4-4-4-2呼吸法でリラックス
・リラクゼーションサウンド - 9種類の環境音
・ジャーナリングプロンプト - 心の整理をサポート

■ 振り返る
・ムードカレンダー - 気分の推移を視覚化
・統計 - 幸福度や瞑想の傾向を分析
・インサイト - あなたのパターンを発見
・週間レポート - 一週間の振り返り

【特徴】
・ダークモード対応
・達成バッジシステムでモチベーション維持
・プライバシー重視 - すべてのデータはデバイス内に保存
・インターネット接続不要

毎日少しずつ、心のケアを始めましょう。
```

**キーワード** (100文字以内):
```
瞑想,マインドフルネス,感謝日記,メンタルヘルス,ウェルネス,睡眠,呼吸法,幸福,気分,日記
```

**サポートURL**: [あなたのサポートページURL]

**プライバシーポリシーURL**: [PRIVACY_POLICY.mdを公開したURL]

### 6.4 スクリーンショット

必要なスクリーンショット：

| デバイス | サイズ | 必須枚数 |
|----------|--------|----------|
| iPhone 6.9" | 1320 x 2868 | 1-10枚 |
| iPhone 6.7" | 1290 x 2796 | 1-10枚 |
| iPhone 6.5" | 1284 x 2778 | 1-10枚 |
| iPhone 5.5" | 1242 x 2208 | 1-10枚 |
| iPad Pro 12.9" | 2048 x 2732 | 1-10枚（iPadサポート時） |

推奨：各サイズ最低3枚

### 6.5 App プライバシー

App Store Connect の「Appのプライバシー」セクションで：

このアプリの場合：
- **データ収集**: なし（すべてローカル保存）
- 「データを収集していません」を選択

## 手順7: 審査への提出

1. すべての必須情報を入力
2. ビルドを選択
3. 「審査に提出」をクリック

### 審査の目安

- 通常1-3日
- リジェクトの場合は修正して再提出

### よくあるリジェクト理由

1. **メタデータの問題** - 説明文やスクリーンショットの不備
2. **バグ** - クラッシュや明らかな不具合
3. **プライバシー** - プライバシーポリシーの不備
4. **ガイドライン違反** - App Store Review Guidelinesに違反

## トラブルシューティング

### ビルドエラー

```bash
# クリーンビルド
flutter clean
flutter pub get
flutter build ios --release
```

### 署名エラー

1. Xcodeで「Signing & Capabilities」を確認
2. Apple Developer Portalで証明書を確認
3. 必要に応じて証明書を再生成

### アップロードエラー

- Xcodeを最新版にアップデート
- インターネット接続を確認
- App Store Connect のステータスを確認

## 公開後の運用

### バージョンアップ

1. `pubspec.yaml` のバージョンを更新
2. 新しいビルドを作成
3. App Store Connect にアップロード
4. 審査に提出

### ユーザーレビューへの対応

- App Store Connect の「評価とレビュー」で確認
- 丁寧に返信して信頼を構築

---

## 重要な注意事項

1. **Macが必須**: iOSアプリのビルドにはmacOSが必要
2. **年間費用**: Apple Developer Program は年間 $99
3. **審査ガイドライン**: [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) を確認
4. **Bundle IDの変更禁止**: 公開後は変更できません
