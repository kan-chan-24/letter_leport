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
      # Docker内ではChromiumを使う（CIには無いので、あるときだけ指定）
      options.binary = "/usr/bin/chromium" if File.exist?("/usr/bin/chromium")
    end
  end
end
