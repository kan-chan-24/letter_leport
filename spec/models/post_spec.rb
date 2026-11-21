require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "バリデーション" do
    it "すべての項目が正しければ有効" do
      expect(build(:post)).to be_valid
    end

    # 3項目の内容が同じためeachで繰り返す
    %i[physical_condition daily_condition fun_condition].each do |attr|
      context "#{attr}について" do
        it "空だと無効" do
          # 配列のattr
          post = build(:post, attr => nil)
          expect(post).to be_invalid
          expect(post.errors[attr]).to be_present
        end

        it "1と5は有効" do
          expect(build(:post, attr => 1)).to be_valid
          expect(build(:post, attr => 5)).to be_valid
        end

        it "0と6は無効" do
          expect(build(:post, attr => 0)).to be_invalid
          expect(build(:post, attr => 6)).to be_invalid
        end
      end
    end

    context "contentについて" do
      it "空でも有効（任意）" do
        expect(build(:post, content: nil)).to be_valid
      end

      it "上限ちょうどの文字数は有効" do
        expect(build(:post, content: "a" * Post::CONTENT_MAX_LENGTH)).to be_valid
      end

      it "上限+1文字だと無効" do
        expect(build(:post, content: "a" * (Post::CONTENT_MAX_LENGTH + 1))).to be_invalid
      end
    end

    context "1期間1投稿について" do
      let(:existing) { create(:post) }

      it "同じユーザーが同じ期間に2回目は投稿できない" do
        second = build(:post, user: existing.user, group: existing.group, timeline_period: existing.timeline_period)
        expect(second).to be_invalid
      end

      it "別のユーザーなら同じ期間に投稿できる" do
        other = build(:post, group: existing.group, timeline_period: existing.timeline_period)
        expect(other).to be_valid
      end
    end
  end

    describe "削除時" do
      it "投稿を削除すると、その投稿についたリアクションも削除される" do
        post = create(:post)
        create(:reaction, post: post)

        expect { post.destroy }.to change(Reaction, :count).by(-1)
      end
    end

  describe "#condition_label" do
    it "値に対応するラベルを返す" do
      post = build(:post, physical_condition: 5)
      expect(post.condition_label(:physical_condition)).to eq "とても快調 🌱"
    end
  end
end
