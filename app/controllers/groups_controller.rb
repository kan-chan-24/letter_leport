class GroupsController < AuthenticatedController
  # ログインユーザーのみのアクセス許可は、authenticated_controllerで済み
  before_action :set_group, only: [ :show, :edit, :update ]
  # グループ設定へのアクセス制限（ホストのみ）
  before_action :require_host, only: [ :edit, :update ]

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

  def edit
    @group_members = @group.group_members.includes(:user)
  end

  def update
    if @group.update(group_settings_params)
      redirect_to edit_group_path(@group), notice: "設定を保存しました"
    else
      flash.now[:alert] = "設定を保存できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # グループを作成する時用
  def group_params
    params.require(:group).permit(:name, :frequency)
  end

  # グループ設定を編集する時用
  def group_settings_params
    params.require(:group).permit(:name, :frequency)
  end

  def set_group
    @group = current_user.groups.find_by(id: params[:id])
    redirect_to mypage_path, alert: "このグループにはアクセスできません" unless @group
  end

  def require_host
    return if @group.host?(current_user)

    redirect_to group_path(@group), alert: "グループ設定はホストのみ操作できます"
  end
end
