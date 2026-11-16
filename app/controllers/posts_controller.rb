class PostsController < AuthenticatedController
  before_action :set_group
  before_action :set_current_period
  before_action :reject_if_already_posted

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.group = @group # URLから取得し、メンバーか確認済みのグループ
    @post.timeline_period = @current_period # サーバーが計算した「今の期間」

    if @post.save
      redirect_to group_path(@group), notice: "近況を知らせました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_group
    # current_user.groups から探すので、メンバーでないグループは見つからず404になる
    @group = current_user.groups.find(params[:group_id])
  end

  def set_current_period
    # 現在の期間を取得
    @current_period = @group.current_period

    # 現在期間が正常に帰ってこなかったり、終わった期間が帰ってきた（ジョブの遅延を考慮）時のガード節
    if @current_period.nil? || @current_period.ended_at <= Time.current
      redirect_to group_path(@group), alert: "現在、投稿できる期間がありません"
    end
  end

  def reject_if_already_posted
    # 現在期間の投稿の中で、ログインユーザーの投稿があるかどうかをチェック
    if @current_period.posts.exists?(user: current_user)
      redirect_to group_path(@group), alert: "今の期間はすでに投稿済みです"
    end
  end

  def post_params
    params.require(:post).permit(:physical_condition, :daily_condition, :fun_condition, :content)
  end
end
