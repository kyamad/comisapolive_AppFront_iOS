# comisapolive.app

## 概要
コミサポライブのライバー情報を閲覧・検索できる iOS アプリです。最新ライバーやコラボ可能なライバー、カテゴリ検索など複数の切り口から配信者を探せます。SwiftUI を中心に構築されており、AdMob 広告や口コミ投稿フローにも対応しています。

## 主な機能
- **ホーム**: 新着ライバーと「コラボ配信OK」ライバーのカルーセル表示、最新記事カード、バナー広告の表示。
- **カテゴリ検索**: ジャンル／配信プラットフォームからライバーを絞り込み、詳細シートでプロフィールや配信リンクを確認。
- **フリーワード検索**: 名前・カテゴリ・コメント・スケジュール情報を横断検索。検索履歴の保存・再利用に対応。
- **ライバー詳細**: プロフィール、フォロワー情報、口コミ評価、配信リンク（`streamingUrls`）を整形して表示。口コミ投稿／閲覧も可能。
- **マイページ**: 外部ウェブページ（SafariView）へ遷移。

## 技術スタック
- Swift 5.9 / SwiftUI
- Combine (`ObservableObject`) ベースの状態管理
- URLSession を用いた API 通信 (`LiverAPIClient`, `ReviewAPIClient`)
- Google Mobile Ads SDK（`Podfile` で導入）

## 開発環境
- macOS / Xcode 15 以上推奨
- iOS 14.0 以降をターゲット
- CocoaPods（`Podfile`）を使用

## セットアップ
1. リポジトリを取得
   ```bash
   git clone <this-repo-url>
   cd comisapolive.app
   ```
2. 依存関係をインストール
   ```bash
   pod install
   ```
3. `comisapolive.app.xcworkspace` を Xcode で開きます。
4. 適切な Team／Bundle Identifier を設定し、シミュレータまたは実機でビルド・実行してください。

## プロジェクト構成（主要ファイル）
- `comisapolive.app/`
  - `HomeView.swift` / `ContentView.swift` / `SearchView.swift` など: 主要画面の SwiftUI 実装。
  - `LiverAPI.swift`: API レスポンスモデルと補助ロジック。`streamingUrls` の整形、プラットフォーム名推定を含む。
  - `ReviewAPI.swift`, `ReviewStatsStore.swift`: 口コミ取得・投稿ロジック。
  - `NewLiverCarousel.swift`, `ColaboLiverCarousel.swift`: ライバーカードのカルーセル UI。
  - `AdMobBannerView.swift`: バナー広告の SwiftUI ラッパー。
  - `DebugLiverDataView.swift`（`#if DEBUG`）: API レスポンスを一覧確認するデバッグ用ビュー。
- `Assets.xcassets/`: アイコン・カテゴリ画像・記事サムネイル等のアセット群。
- `Pods/`: CocoaPods により取得した依存ライブラリ。

## API とデータ
- `LiverAPIClient` が Cloudflare Workers 経由のエンドポイントからライバー一覧・詳細を取得し、`Liver` モデルにマッピングしています。
- `streamingUrls` の `type` や `source` が汎用文字列の場合でも URL のドメインからプラットフォーム名を推定し、ライバー詳細のボタンラベルとして表示します。
- `ReviewAPIClient` は平均評価・口コミリスト・投稿 API をハンドリングします。投稿成功後にキャッシュを更新し、`UserDefaultsManager` で投稿済みフラグを保持します。

## 広告
- `AdMobBannerView` に adUnitID を渡してバナーを表示しています。新規ユニットを追加する際は `AdMobBannerView` を再利用してください。

## デバッグ支援
- **DebugLiverDataView** (`#if DEBUG`): ライバーの一覧・詳細レスポンスをその場で確認できます。
- **Previews**: 各ビューにサンプルデータ付きの Preview が用意されているため、UI 調整時に活用してください。

## コード整理の指針
- 不要コンポーネントや旧 UI ファイルは削除済みです。新たに未使用コードが発生した場合は `rg` 等で参照確認後に削除してください。
- デバッグ用コードは `#if DEBUG` ブロックにまとめ、本番ビルドへ影響しないように管理します。

## ライセンス
プロジェクト内に明示的なライセンスファイルは含まれていません。必要に応じて追加してください。

