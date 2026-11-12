class NotificationMailer < ApplicationMailer
  def report_reminder
    # .with(user:, group:)で渡された値を受け取る
    @user  = params[:user]
    @group = params[:group]

    today  = Date.current # 送信日を"今日"として取得
    @month = today.month # 月を取得
    @week = (today.day - 1) / 7 + 1 # 〇月"〇週目"の部分を算出

    mail(
      # 宛先
      to: @user.email,
      # 件名
      subject: "#{@month}月#{@week}週目 #{@group.name}の近況報告のタイミングがきました！"
    )
  end
end
