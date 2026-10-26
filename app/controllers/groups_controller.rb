class GroupsController < ApplicationController
  # ログインユーザーのみアクセス許可
  before_action :authenticate_user!

  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(group_params)

    # 対応表を引いて、interval_unit・interval_count を代入
    preset = Group::FREQUENCY_PRESET[frequency_key]
    if preset.nil?
      flash.now[:alert] = "通知頻度を選択してください"
      return render :new, status: :unprocessable_entity
    end
    @group.interval_unit = preset[:interval_unit]
    @group.interval_count = preset[:interval_count]
  
    # Service で初回の通知日時を計算して代入
    @group.next_notify_at = NotifyAtCalculator.first_notify_at(
      base_time: Time.current,
      interval_unit: @group.interval_unit,
      notify_day_of_week: @group.notify_day_of_week,
      notify_day_of_month: @group.notify_day_of_month,
      notify_hour: @group.notify_hour
    )

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
    params.require(:group).permit(:name)
  end

  def frequency_key
    params.dig(:group, :frequency)&.to_sym
  end
end
