class GroupMembersController < AuthenticatedController
  def create
    # グループ参加処理（グループメンバーか
    group = Group.find_by!(invitation_token: params[:invitation_token])

    # メンバー表に新レコード（新ユーザー）を作成
    member = @group.group_members.find_or_create_by(user: current_user) do |member|
      member.role = :member
    end
  
    # 直前の保存で新しく作られたレコードだった場合、trueを返す
    if member.previously_new_record?
      flash[:notice] = "#{group.name}に参加しました"
    end

    redirect_to group_path(group)
  end
end