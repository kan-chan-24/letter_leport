class ApplicationMailer < ActionMailer::Base
  # 受信箱でふしメモと表示される
  default from: "ふしメモ <notice@fushimemo.com>"
  layout "mailer"
end
