require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "FactoryBotのデフォルト値で有効であること" do
      expect(build(:user)).to be_valid
    end

    # 存在テスト
    context "name" do
      it "空だと無効" do
        user = build(:user, name: "")
        expect(user).to be_invalid
        expect(user.errors).to be_of_kind(:name, :blank)
      end

      # length制限テスト
      it "21文字以上だと無効" do
        user = build(:user, name: "a" * 21)
        expect(user).to be_invalid
      end

      it "20文字なら有効" do
        expect(build(:user, name: "a" * 20)).to be_valid
      end
    end

    context "email" do
      it "空だと無効" do
        user = build(:user, email: "")
        expect(user).to be_invalid
        expect(user.errors).to be_of_kind(:email, :blank)
      end

      it "形式が不正だと無効" do
        user = build(:user, email: "invalid_email")
        expect(user).to be_invalid
      end

      it "重複したemailは登録できない" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")
        expect(user).to be_invalid
        expect(user.errors).to be_of_kind(:email, :taken)
      end

      it "大文字小文字が違うだけの重複も登録できない" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "TEST@example.com")
        expect(user).to be_invalid
      end
    end

    context "password" do
      it "空だと無効" do
        user = build(:user, password: "", password_confirmation: "")
        expect(user).to be_invalid
      end

      it "5文字だと無効、6文字だと有効" do
        expect(build(:user, password: "a" * 5, password_confirmation: "a" * 5)).to be_invalid
        expect(build(:user, password: "a" * 6, password_confirmation: "a" * 6)).to be_valid
      end

      it "確認用と一致しないと無効" do
        user = build(:user, password: "password", password_confirmation: "different")
        expect(user).to be_invalid
      end
    end
  end
end
