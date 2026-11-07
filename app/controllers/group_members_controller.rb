class GroupMembersController < AuthenticatedController
  def create
    # グループ参加処理（グループメンバーか
    group = Group.find_by!(invite_token: params[:invitation_token])

    # メンバー表に新レコード（新ユーザー）を作成
    member = group.add_member(current_user)

    # 直前の保存で新しく作られたレコードだった場合、trueを返す
    if member.previously_new_record?
      flash[:notice] = "#{group.name}に参加しました"
    end

    redirect_to group_path(group)
  end

  def destroy
    group = Group.find(params[:group_id])
    member = group.group_members.find(params[:id])

    member.destroy
    redirect_to edit_group_path(group),
                notice: "#{group_member.user.name}さんをグループから外しました",
                status: :see_other
  end
end
