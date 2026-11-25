RSpec.configure do |config|
  # system spec はすべて rack_test（JSなし・速い）で動かす
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end