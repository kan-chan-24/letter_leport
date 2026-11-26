RSpec.configure do |config|
  # system spec はすべて rack_test（JSなし・速い）で動かす
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # js: true を付けたテストだけ、headless Chrome で動かす
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1000 ] do |options|
      # Docker内ではChromeの安全機能（サンドボックス）が動かないので無効にする
      options.add_argument("--no-sandbox")
      # Docker内の共有メモリが小さく、Chromeが落ちることがあるのを防ぐ
      options.add_argument("--disable-dev-shm-usage")

      # 使うChromeの場所を決める
      if ENV["CHROME_BIN"].present?
        # CI：setup-chromeで入れたChrome 157を使う
        # （Chrome 158とCapybara 3.40.0の相性問題の回避。Capybaraの修正版が出たら外す）
        options.binary = ENV["CHROME_BIN"]
      elsif File.exist?("/usr/bin/chromium")
        # Docker内：Chromiumを使う
        options.binary = "/usr/bin/chromium"
      end
    end
  end
end
