require "rails_helper"

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let!(:membership) { create(:group_member, group: group, user: user) }
  let!(:period) do
    group.current_period || create(:timeline_period, group: group, started_at: 1.day.ago, ended_at: 1.week.from_now)
  end

  let(:valid_params) do
    { post: { physical_condition: 4, daily_condition: 3, fun_condition: 5, content: "朝は寒くなってきたね" } }
  end

  describe "GET /groups/:group_id/posts/new" do
    context "未ログインの場合" do
      it "ログイン画面へリダイレクトされる" do
        get new_group_post_path(group)
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "メンバーで未投稿なら表示できる" do
        get new_group_post_path(group)
        expect(response).to have_http_status(:ok)
      end

      it "今の期間に投稿済みならTLへリダイレクトされる" do
        create(:post, user: user, group: group, timeline_period: period)
        get new_group_post_path(group)
        expect(response).to redirect_to group_path(group)
      end

      it "メンバーでないグループならマイページへリダイレクトされる" do
        other_group = create(:group)
        get new_group_post_path(other_group)
        expect(response).to redirect_to mypage_path
      end

      it "今の期間が終わっていればTLへリダイレクトされる" do
        period.update!(ended_at: 1.minute.ago)
        get new_group_post_path(group)
        expect(response).to redirect_to group_path(group)
      end
    end
  end

  describe "POST /groups/:group_id/posts" do
    before { sign_in user }

    context "入力が正しい場合" do
      it "投稿が作成され、今の期間・本人がひもづく" do
        expect {
          post group_posts_path(group), params: valid_params
        }.to change(Post, :count).by(1)

        created = Post.last
        expect(created.user).to eq user
        expect(created.timeline_period).to eq period
      end

      it "TLへリダイレクトされ、メッセージが表示される" do
        post group_posts_path(group), params: valid_params
        expect(response).to redirect_to group_path(group)

        follow_redirect!
        expect(response.body).to include "近況を知らせました"
      end
    end

    context "3項目のどれかが未選択の場合" do
      it "投稿されず、エラーで再表示される" do
        params = valid_params.deep_merge(post: { physical_condition: nil })

        expect {
          post group_posts_path(group), params: params
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "同じ期間に2回目の投稿をした場合" do
      it "投稿されない" do
        create(:post, user: user, group: group, timeline_period: period)

        expect {
          post group_posts_path(group), params: valid_params
        }.not_to change(Post, :count)
      end
    end

    context "メンバーでないグループに投稿した場合" do
      it "投稿されない" do
        other_group = create(:group)

        expect {
          post group_posts_path(other_group), params: valid_params
        }.not_to change(Post, :count)
      end
    end
  end

  describe "TL画面の「近況を書き始める」ボタン" do
    before { sign_in user }

    it "未投稿なら表示される" do
      get group_path(group)
      expect(response.body).to include "近況を書き始める"
    end

    it "投稿済みなら表示されない" do
      create(:post, user: user, group: group, timeline_period: period)
      get group_path(group)
      expect(response.body).not_to include "近況を書き始める"
    end
  end
end
