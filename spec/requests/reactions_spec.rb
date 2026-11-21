require "rails_helper"

RSpec.describe "Reactions", type: :request do
  let(:user) { create(:user) }
  let(:target_post) { create(:post) }       # ← `post` という名前は使わない（理由は下で説明）
  let(:group) { target_post.group }

  before { sign_in user }

  context "グループのメンバーのとき" do
    before { create(:group_member, group: group, user: user) }

    it "👍を押すと1増える" do
      expect {
        post group_post_reactions_path(group, target_post), params: { stamp: "thumbs_up" }, as: :turbo_stream
      }.to change(Reaction, :count).by(1)
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
    end

    it "同じ投稿に2回押しても1つしか付かない" do
      2.times { post group_post_reactions_path(group, target_post), params: { stamp: "thumbs_up" }, as: :turbo_stream }
      expect(Reaction.count).to eq 1
    end

    it "自分の👍をもう一度押すと1減る" do
      reaction = create(:reaction, user: user, post: target_post)
      expect {
        delete group_post_reaction_path(group, target_post, reaction), as: :turbo_stream
      }.to change(Reaction, :count).by(-1)
    end

    it "他人の👍は外せない" do
      others = create(:reaction, post: target_post)
      expect {
        delete group_post_reaction_path(group, target_post, others), as: :turbo_stream
      }.not_to change(Reaction, :count)
    end
  end

  context "グループのメンバーでないとき" do
    it "👍できず、マイページへ戻される" do
      expect {
        post group_post_reactions_path(group, target_post), params: { stamp: "thumbs_up" }, as: :turbo_stream
      }.not_to change(Reaction, :count)
      expect(response).to redirect_to(mypage_path)
    end
  end
end
