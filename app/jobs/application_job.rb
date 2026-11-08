class ApplicationJob < ActiveJob::Base
  # どこにキューを入れるかを一応defaultに指定
  queue_as :default

  # テスト的なジョブ
  def perform(name)
    Rails.logger.info("SampleJobを開始します：#{name}")
    sleep(5) # 時間のかかる処理を再現
    Rails.logger.info("SampleJobが完了しました：#{name}")
  end
end
