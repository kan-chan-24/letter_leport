class GroupsController < AuthenticatedController
  # ログインユーザーのみアクセス許可は、authenticated_controllerで済み
  before_action :set_group, only: [ :show ]

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)

    # 作成者を host として仕込む（save 時にまとめて保存される）
    @group.group_members.build(user_id: current_user.id, role: :host)

    if @group.save
      redirect_to group_path(@group), notice: "グループを作成しました"
    else
      flash.now[:alert] = "グループを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # before_actionで@groupはセット済みなので、すでに@groupが使用可能な状態
  end

  private

  def group_params
    params.require(:group).permit(:name, :frequency)
  end

  def set_group
    @group = current_user.groups.find_by(id: params[:id])
    redirect_to mypage_path, alert: "このグループにはアクセスできません" unless @group
  end
end
