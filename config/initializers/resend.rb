# アプリ起動時に1回だけ自動で読み込まれる設定ファイル
# キーの値は環境変数から読み込む
# 開発環境ではnilになるが、letter_openerを使うので問題なし（本番では値が入る）
Resend.api_key = ENV["RESEND_API_KEY"]
