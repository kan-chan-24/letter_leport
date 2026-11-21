require "rails_helper"

RSpec.describe Reaction, type: :model do
  # 比較の元になる「すでに保存済みの👍」
  let!(:reaction) { create(:reaction) }

  describe "バリデーション" do
    it "user・post・stampがそろっていれば有効" do
      expect(build(:reaction)).to be_valid
    end

    it "stampを指定しなければthumbs_upになる" do
      expect(Reaction.new.stamp).to eq "thumbs_up"
    end

    it "同じユーザーが同じ投稿に同じスタンプを2回付けられない" do
      duplicate = build(:reaction, user: reaction.user, post: reaction.post, stamp: reaction.stamp)
      expect(duplicate).to be_invalid
    end

    it "stampが空なら無効" do
      expect(build(:reaction, stamp: nil)).to be_invalid
    end

    it "対応表にないstampなら無効（例外ではなくバリデーションエラーになる）" do
      expect(build(:reaction, stamp: "hoge")).to be_invalid
    end
  end

  describe "DB制約" do
    it "バリデーションをすり抜けても、同じ組み合わせはDBが保存させない" do
      duplicate = build(:reaction, user: reaction.user, post: reaction.post, stamp: reaction.stamp)
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
