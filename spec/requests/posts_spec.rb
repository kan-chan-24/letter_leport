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

  describe "GET /groups/:group_id/posts/:id/edit" do
    before { sign_in user }

    let(:other_user) { create(:user) }
    let!(:my_post) { create(:post, user: user, group: group, timeline_period: period) }

    it "自分の今期の投稿なら表示できる" do
      get edit_group_post_path(group, my_post)
      expect(response).to have_http_status(:ok)
    end

    it "他人の投稿は404になる" do
      others_post = create(:post, user: other_user, group: group, timeline_period: period)
      get edit_group_post_path(group, others_post)
      expect(response).to have_http_status(:not_found)
    end

    it "過去の期間の投稿はTLへリダイレクトされる" do
      past_period = create(:timeline_period, group: group, started_at: period.started_at - 7.days, ended_at: period.started_at)
      past_post = create(:post, user: user, group: group, timeline_period: past_period)

      get edit_group_post_path(group, past_post)
      expect(response).to redirect_to group_path(group)
    end
  end

  describe "PATCH /groups/:group_id/posts/:id" do
    before { sign_in user }

    let!(:my_post) { create(:post, user: user, group: group, timeline_period: period, content: "変更前") }

    context "入力が正しい場合" do
      it "投稿が更新され、TLにメッセージが表示される" do
        patch group_post_path(group, my_post), params: { post: { content: "変更後" } }

        expect(my_post.reload.content).to eq "変更後"
        expect(response).to redirect_to group_path(group)

        follow_redirect!
        expect(response.body).to include "近況を更新しました"
      end
    end

    context "3項目のどれかが未選択の場合" do
      it "更新されず、エラーで再表示される" do
        patch group_post_path(group, my_post), params: { post: { physical_condition: nil } }

        expect(my_post.reload.physical_condition).not_to be_nil
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "他人の投稿の場合" do
      it "404になり、更新されない" do
        others_post = create(:post, user: create(:user), group: group, timeline_period: period, content: "他人の投稿")

        patch group_post_path(group, others_post), params: { post: { content: "書き換え" } }

        expect(response).to have_http_status(:not_found)
        expect(others_post.reload.content).to eq "他人の投稿"
      end
    end
  end

  describe "DELETE /groups/:group_id/posts/:id" do
    let(:other_user) { create(:user) }
    let!(:my_post) { create(:post, user: user, group: group, timeline_period: period) }

    context "未ログインの場合" do
      it "削除されず、ログイン画面へリダイレクトされる" do
        expect {
          delete group_post_path(group, my_post)
        }.not_to change(Post, :count)

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "ログイン済みの場合" do
      before { sign_in user }

      it "自分の投稿が削除され、TLにメッセージが表示される" do
        expect {
          delete group_post_path(group, my_post)
        }.to change(Post, :count).by(-1)

        expect(response).to redirect_to group_path(group)

        follow_redirect!
        expect(response.body).to include "近況を削除しました"
      end

      it "他人の投稿は404になり、削除されない" do
        others_post = create(:post, user: other_user, group: group, timeline_period: period)

        expect {
          delete group_post_path(group, others_post)
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:not_found)
      end

      it "削除後、同じ期間にもう一度投稿できる" do
        delete group_post_path(group, my_post)

        expect {
          post group_posts_path(group), params: valid_params
        }.to change(Post, :count).by(1)
      end
    end
  end

  describe "メンバーでないユーザーの場合" do
    let(:outsider) { create(:user) } # グループに入っていないユーザー
    let!(:member_post) { create(:post, user: user, group: group, timeline_period: period, content: "メンバーの投稿") }

    before { sign_in outsider }

    it "編集画面を開けず、マイページへリダイレクトされる" do
      get edit_group_post_path(group, member_post)
      expect(response).to redirect_to mypage_path
    end

    it "更新できず、マイページへリダイレクトされる" do
      patch group_post_path(group, member_post), params: { post: { content: "書き換え" } }

      expect(response).to redirect_to mypage_path
      expect(member_post.reload.content).to eq "メンバーの投稿"
    end

    it "削除できず、マイページへリダイレクトされる" do
      expect {
        delete group_post_path(group, member_post)
      }.not_to change(Post, :count)

      expect(response).to redirect_to mypage_path
    end
  end
end
