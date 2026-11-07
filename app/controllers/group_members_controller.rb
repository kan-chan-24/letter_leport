class GroupMembersController < AuthenticatedController
  before_action :set_group, only: [ :destroy ]
  before_action :require_host, only: [ :destroy ]
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
    member = @group.group_members.find(params[:id])

    # ホスト自身は外せない
    if member.host?
      redirect_to edit_group_path(@group), alert: "ホストはグループから外せません", status: :see_other
      return
    end

    member.destroy
    redirect_to edit_group_path(@group),
                notice: "#{member.user.name}さんをグループから外しました",
                status: :see_other
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  # 操作している人がこのグループのホストか
  def require_host
    return if @group.group_members.find_by(user: current_user)&.host?

    redirect_to group_path(@group), alert: "この操作はホストのみ行えます", status: :see_other
  end
end
