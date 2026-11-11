require "rails_helper"

RSpec.describe "Cron::Notifications", type: :request do
  let(:secret) { "test_secret" }

  before do
    # CRON_SECRETの環境変数だけ聞かれた時は、テスト用のsecretを返す
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CRON_SECRET").and_return(secret)
  end

  describe "POST /cron/notification" do
    context "正しい合言葉のとき" do
      let(:headers) { { "Authorization" => "Bearer #{secret}" } }

      it "通知ジョブを登録すること" do
        expect {
          post cron_notification_path, headers: headers
        }.to have_enqueued_job(GroupNotificationJob)
      end

      it "202を返すこと" do
        post cron_notification_path, headers: headers
        expect(response).to have_http_status(:accepted)
      end
    end

    context "間違った合言葉のとき" do
      let(:headers) { { "Authorization" => "Bearer wrong_secret" } }

      it "通知ジョブを登録しないこと" do
        expect {
          post cron_notification_path, headers: headers
        }.not_to have_enqueued_job(GroupNotificationJob)
      end

      it "401を返すこと" do
        post cron_notification_path, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "ヘッダーがないとき" do
      it "通知ジョブを登録しないこと" do
        expect {
          post cron_notification_path
        }.not_to have_enqueued_job(GroupNotificationJob)
      end

      it "401を返すこと" do
        post cron_notification_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "環境変数が設定されていないとき" do
      let(:secret) { nil }

      it "空の合言葉でもジョブを登録しないこと" do
        expect {
          post cron_notification_path, headers: { "Authorization" => "Bearer " }
        }.not_to have_enqueued_job(GroupNotificationJob)
      end
    end
  end
end
