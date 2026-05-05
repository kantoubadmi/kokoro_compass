# こころコンパス リリース作業 - 次のステップ

## 進行状況

- [x] アプリアイコン作成（assets/icon/app_icon.png）
- [x] pubspec.yaml にflutter_launcher_icons追加
- [x] Bundle ID 確認（com.kokorocompass.app で統一済み）
- [x] App Store / Google Play メタデータ作成（STORE_METADATA.md）
- [x] codemagic.yaml 作成
- [x] プライバシーポリシーHTML作成（docs/index.html）
- [ ] **Apple Developer Program 登録（あなたの作業中）**
- [ ] GitHubリポジトリ作成
- [ ] GitHub Pages でプライバシーポリシー公開
- [ ] flutter_launcher_icons 実行（全サイズアイコン生成）
- [ ] Codemagic 連携設定
- [ ] App Store Connect でアプリ登録
- [ ] スクリーンショット撮影
- [ ] 初回ビルド＆TestFlightアップロード
- [ ] App Store審査提出

---

## あなたの作業 - 手順詳細

### Step A：GitHub リポジトリの作成（5分）

GitHubの自分のアカウントにログインして、新規リポジトリを作成してください。

1. https://github.com/new にアクセス
2. リポジトリ名: `kokoro_compass`
3. **Public** を選択（GitHub Pages 無料利用のため）
4. 「Create repository」をクリック

作成後、ローカルマシンで以下のコマンドを実行：

```bash
cd C:\work\python\generated_apps\kokoro_compass

# .gitignore はFlutterが自動生成しているはず
# Git 初期化
git init
git add .
git commit -m "Initial commit: ready for App Store release"

# リモート追加（YOUR_USERNAMEを置き換え）
git remote add origin https://github.com/YOUR_USERNAME/kokoro_compass.git
git branch -M main
git push -u origin main
```

push が成功すると、リポジトリにコードが上がります。

### Step B：GitHub Pages でプライバシーポリシー公開（3分）

1. GitHub の `kokoro_compass` リポジトリページに移動
2. 「Settings」タブ → 左サイドバーの「Pages」
3. 「Build and deployment」セクション：
   - Source: **Deploy from a branch**
   - Branch: **main** / Folder: **/docs**
4. 「Save」をクリック
5. 数分後、以下の URL でアクセス可能になります：
   ```
   https://YOUR_USERNAME.github.io/kokoro_compass/
   ```
6. このURLを **STORE_METADATA.md のプライバシーポリシーURL欄** にメモ

確認方法：URLにブラウザでアクセスし、「こころコンパス プライバシーポリシー」と表示されればOK。

### Step C：flutter_launcher_icons でアイコン全サイズ生成（5分）

ローカルのkokoro_compassディレクトリで以下を実行：

```bash
cd C:\work\python\generated_apps\kokoro_compass
flutter pub get
dart run flutter_launcher_icons
```

これでiOSとAndroidの全サイズのアプリアイコンが自動生成されます。エラーが出たら教えてください。

実行後、git commit & push しておきます：

```bash
git add .
git commit -m "Generate launcher icons for all sizes"
git push
```

### Step D：実機（Android端末）で動作確認（10分）

リリース前に実機テストすることが**極めて重要**です。

```bash
# Android端末をUSB接続（USBデバッグON）
flutter devices  # 端末が認識されることを確認
flutter run --release  # リリースモードでビルド・実行
```

すべての主要機能（感謝日記、瞑想、呼吸法、睡眠記録、気分記録）が正しく動作することを確認してください。クラッシュやUI崩れがあれば教えてください、修正します。

### Step E：Apple Developer 承認待ち（24-48時間）

申請完了後、Appleからメール（subject: "Welcome to the Apple Developer Program"）が届くまで待ちます。承認後に Step F へ。

---

## Step F〜I：Apple Developer 承認後の作業（あなたの作業 + 私のサポート）

### Step F：App Store Connect でアプリ登録

1. https://appstoreconnect.apple.com/ にログイン
2. 「マイApp」 → 「+」 → 「新規App」
3. 入力：
   - プラットフォーム: iOS
   - 名前: こころコンパス
   - プライマリ言語: 日本語
   - バンドルID: com.kokorocompass.app（プルダウンで選ぶ）
   - SKU: kokorocompass001
4. 「作成」

アプリ登録後の **Apple ID（数字）** を控えておく → codemagic.yaml の `APP_STORE_APPLE_ID` を更新します。

### Step G：Codemagic アカウント登録 & 設定

1. https://codemagic.io/signup でGitHubサインイン
2. ダッシュボード → 「Add application」 → kokoro_compass リポジトリを選択
3. ワークフロー設定 → 「Use codemagic.yaml」を選択
4. 「App Store Connect」インテグレーションをセットアップ：
   - Codemagic → Teams → Integrations → 「App Store Connect」
   - Issuer ID、Key ID、API Private Key を入力（App Store Connect で発行）

### Step H：スクリーンショット撮影

iOS用スクリーンショットが必要：
- 6.7インチ (iPhone 15 Pro Max): 1290×2796 px、6〜10枚
- 6.5インチ (iPhone 11 Pro Max): 1242×2688 px、6〜10枚

Macなしの場合の代替案：
1. **Android端末で撮影**して、後で「fastlane frameit」や「screenshot framer」でiPhoneフレームに合成
2. **シミュレーターサービス**を使う（[Previewed.app](https://previewed.app/) は無料枠あり）
3. **AppMockUp**（https://app-mockup.com/）でWeb上で生成

→ 撮影が完了したら教えてください、フレーム合成・整形をサポートします。

### Step I：初回ビルド & TestFlight アップロード

Codemagicのダッシュボードで「ios-release」ワークフローを手動トリガーするか、git push で自動ビルドされます。

ビルド成功 → App Store Connect → TestFlight に自動アップロードされます。
TestFlightで自分の端末（または家族・友人）にインストールして最終動作確認。

### Step J：App Store審査提出

1. App Store Connect → アプリ → 「ストア掲載情報」
2. STORE_METADATA.md の内容を全項目に貼り付け
3. プライバシーポリシーURL、サポートURLを入力
4. スクリーンショットをアップロード
5. ビルドを選択（TestFlightにアップ済みのもの）
6. 「審査へ提出」をクリック

通常24〜48時間で審査結果が来ます。

---

## トラブルシューティング

### git push でエラー（authentication failed）
GitHubは2021年からパスワード認証廃止。Personal Access Token を使ってください：
1. GitHub → Settings → Developer Settings → Personal Access Tokens → Generate new token
2. 「repo」スコープ選択
3. 生成されたトークンをパスワード代わりに使う

### Codemagic ビルドが署名エラーで失敗
App Store Connect APIキーの権限が不足している可能性。
Codemagic ドキュメント: https://docs.codemagic.io/yaml-code-signing/distribution/

### flutter_launcher_icons で「Image not found」
画像パスを `pubspec.yaml` で確認：`assets/icon/app_icon.png` が正しい場所にあるか。

---

## 私のサポート範囲

以下はいつでも私が対応できます：

- スクリーンショット撮影後の整形・iPhoneフレーム合成
- App Store Connect の英語表記・翻訳サポート
- Codemagic のビルドエラー解析
- 審査リジェクト時の対応文面作成
- アプリ内バグ発見時の修正

何か詰まったらすぐに教えてください。
