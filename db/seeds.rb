# 開発環境の動作確認用データ（N+1チェック用）
# 本番で db:seed が実行されてもテスト用データが入らないよう、開発環境だけに限定する
return unless Rails.env.development?

puts "seed: ユーザーを作成中..."
users = (1..6).map do |i|
  # find_or_create_by! … あれば取得、なければブロックの中身で作成（何回実行しても重複しない）
  User.find_or_create_by!(email: "user#{i}@example.com") do |user|
    user.name = "ユーザー#{i}"
    user.password = "password"
  end
end

group_settings = [
  { name: "実家のみんな",   host: users[0], members: users[1..3],                  frequency: "one_week",    leave_unposted: true },
  { name: "大学の友だち",   host: users[0], members: users[3..5],                  frequency: "one_month",   leave_unposted: false },
  { name: "前の職場の同期", host: users[1], members: [users[0], users[4], users[5]], frequency: "three_month", leave_unposted: false }
]

contents = [
  "最近は朝の散歩を続けています。",
  "仕事がバタバタしていたけど、やっと落ち着きました！",
  "週末にパンを焼きました🍞",
  nil # 自由入力は任意なので、空の投稿も混ぜる
]

group_settings.each do |setting|
  puts "seed: #{setting[:name]} を作成中..."

  # グループ作成（コントローラーと同じく、ホストをbuildで仕込んでからまとめて保存）
  # 作成時に after_create で「最初の期間」も自動で作られる
  group = Group.find_or_create_by!(name: setting[:name]) do |g|
    g.frequency = setting[:frequency]
    g.group_members.build(user: setting[:host], role: :host)
  end

  # メンバー参加（add_memberは既に参加済みなら何もしない）
  setting[:members].each { |user| group.add_member(user) }

  # 過去の期間を2つ作る（作成日時を基準に、頻度1回分ずつさかのぼる）
  # beginning_of_hourで秒以下を切り捨てて、再実行しても同じ日時になるようにしている
  span = group.week? ? group.interval_count.weeks : group.interval_count.months
  base = group.created_at.beginning_of_hour
  [ 2, 1 ].each do |n|
    started_at = base - (span * n)
    group.timeline_periods.find_or_create_by!(started_at: started_at) do |period|
      period.ended_at = started_at + span
    end
  end

  # 投稿：全期間 × 全メンバー
  members = group.users.to_a
  current = group.current_period
  group.timeline_periods.each do |period|
    members.each do |user|
      # 今の期間だけ user1 を未投稿にしておく（「近況を書き始める」ボタン確認用）
      next if setting[:leave_unposted] && period == current && user == users[0]

      group.posts.find_or_create_by!(user: user, timeline_period: period) do |post|
        post.physical_condition = rand(1..5)
        post.daily_condition    = rand(1..5)
        post.fun_condition      = rand(1..5)
        post.content            = contents.sample
      end
    end
  end

  # 👍：投稿者以外のメンバーから0〜3人をランダムに
  group.posts.each do |post|
    members.reject { |u| u.id == post.user_id }.sample(rand(0..3)).each do |user|
      post.reactions.find_or_create_by!(user: user, stamp: :thumbs_up)
    end
  end
end

puts "seed: 完了！ User:#{User.count} Group:#{Group.count} Period:#{TimelinePeriod.count} Post:#{Post.count} Reaction:#{Reaction.count}"
