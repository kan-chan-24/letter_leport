module Cron
  class NotificationsController < ActionController::API
    before_action :verify_cron_token

    def create
      # 通知日時更新ジョブを登録する
      GroupNotificationJob.perform_later
      # 202（処理受付OK、後でやるね）を返す
      head :accepted
    end

    private

    # アクセスの合言葉チェック（不正なアクセスではないか）
    def verify_cron_token
      # 環境変数から正解の合言葉を取得
      expected = ENV["CRON_SECRET"]
      # cron-job.orgがアクセスしてきた時の合言葉部分を抽出する
      given = request.headers["Authorization"].to_s.delete_prefix("Bearer ")

      # 合言葉がOKならここで処理終了→createアクションへ。NGなら下へ
      # チェック内容：expected（環境変数で設定された合言葉）の入力忘れをチェック＋ヘッダーの合言葉と環境変数の合言葉の照合
      return if expected.present? && ActiveSupport::SecurityUtils.secure_compare(given, expected)

      # 今回のリクエストへのレスポンスは401を返す→レスポンスは返し終わったので、createへはいかない
      head :unauthorized
    end
  end
end
