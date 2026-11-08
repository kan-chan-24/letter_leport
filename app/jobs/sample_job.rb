class SampleJob < ApplicationJob
  queue_as :default

  def perform(name)
    # Do something later
    Rails.logger.info("SampleJobを開始します：#{name}")
    sleep(5) # 時間のかかる処理を再現
    Rails.logger.info("SampleJobが完了しました：#{name}")
  end
end
