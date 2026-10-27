require 'rails_helper'

RSpec.describe "Groups", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "POST /groups" do
    context "正しい値のとき" do
      let(:params) { { group: { name: "家族", frequency: "six_month" } } }

      it "グループが作成される" do
        expect { post groups_path, params: params }.to change(Group, :count).by(1)
      end

      it "作成者がホストとして登録される" do
        post groups_path, params: params
        member = Group.last.group_members.find_by(user: user)
        expect(member).to be_host
      end

      it "通知頻度が interval_unit・interval_count に変換されて保存される" do
        post groups_path, params: params
        group = Group.last
        expect(group.interval_unit).to eq "month"
        expect(group.interval_count).to eq 6
      end

      it "招待トークンが保存される" do
        post groups_path, params: params
        expect(Group.last.invite_token).to be_present
      end

      it "TL画面へリダイレクトする" do
        post groups_path, params: params
        expect(response).to redirect_to(group_path(Group.last))
      end
    end

    context "次回通知日時" do
      it "月単位なら、次の1日の9時が保存される" do
        travel_to Time.zone.local(2026, 10, 27, 12, 0) do
          post groups_path, params: { group: { name: "家族", frequency: "six_month" } }
        end
        expect(Group.last.next_notify_at).to eq Time.zone.local(2026, 11, 1, 9, 0)
      end

      it "週単位なら、次の月曜日の9時が保存される" do
        travel_to Time.zone.local(2026, 10, 27, 12, 0) do
          post groups_path, params: { group: { name: "家族", frequency: "one_week" } }
        end
        expect(Group.last.next_notify_at).to eq Time.zone.local(2026, 11, 2, 9, 0)
      end
    end

    context "通知頻度が未選択のとき" do
      let(:params) { { group: { name: "家族" } } }

      it "グループもメンバーも作成されない" do
        expect { post groups_path, params: params }
          .to change(Group, :count).by(0)
          .and change(GroupMember, :count).by(0)
      end

      it "作成画面を再表示する" do
        post groups_path, params: params
        expect(response).to have_http_status(422)
      end
    end

    context "グループ名が空のとき" do
      it "グループもメンバーも作成されない" do
        expect { post groups_path, params: { group: { name: "", frequency: "one_week" } } }
          .to change(Group, :count).by(0)
          .and change(GroupMember, :count).by(0)
      end
    end

    describe "GET /groups/:id" do
      let(:group) { create(:group) }

      it "参加しているグループは表示できる" do
        group.group_members.create!(user: user, role: :host)
        get group_path(group)
        expect(response).to have_http_status(200)
      end

      it "参加していないグループは404になる" do
        get group_path(group)
        expect(response).to have_http_status(404)
      end
    end
  end
end
