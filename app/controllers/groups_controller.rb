class GroupsController < ApplicationController
  # ログインユーザーのみアクセス許可
  before_action :authenticate_user!

  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(group_params)

    # 作成者を host として仕込む（save 時にまとめて保存される）
    @group.group_members.build(user: current_user, role: :host)


    if @group.save
      redirect_to group_path(@group), notice: "グループを作成しました"
    else
      flash.now[:alert] = "グループを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @group = current_user.groups.find(params[:id])
  end

  private

  def group_params
    params.require(:group).permit(:name, :frequency)
  end
end
