class PostsController < AuthenticatedController
  before_action :set_group
  before_action :set_post, only: %i[edit update]
  before_action :set_current_period
  before_action :reject_if_already_posted, only: %i[new create]
  before_action :require_current_period, only: %i[edit update]

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

  def edit
  end

  def update
    # フォームから受けとった内容で投稿を更新
    if @post.update(post_params)
      # グループのTL画面へ戻る
      redirect_to group_path(@group), notice: "近況を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_group
    # current_user.groups から探すので、メンバーでないグループは見つからずマイページへ返される
    @group = current_user.groups.find_by(id: params[:group_id])
    redirect_to mypage_path, alert: "このグループにはアクセスできません" unless @group
  end

  def set_post
    # ログインユーザーの投稿を取得
    @post = current_user.posts.find(params[:id])
  end

  def set_current_period
    # 現在の期間を取得
    @current_period = @group.current_period

    # 現在期間が正常に帰ってこなかったり、終わった期間が帰ってきた（ジョブの遅延を考慮）時のガード節
    redirect_to group_path(@group), alert: "現在、投稿できる期間がありません" unless @current_period&.active?
  end

  def reject_if_already_posted
    # 現在期間の投稿の中で、ログインユーザーの投稿があるかどうかをチェック
    if @current_period.posted_by?(current_user)
      redirect_to group_path(@group), alert: "今の期間はすでに投稿済みです"
    end
  end

  def require_current_period
    # @postの期間idとグループに紐づく期間idが同じならOK
    return if @post.timeline_period_id == @current_period&.id

    # 同じじゃないなら、現在以外の期間の投稿を参照しようとしている→弾く
    redirect_to group_path(@group), alert: "過去の近況は編集できません"
  end

  def post_params
    params.require(:post).permit(:physical_condition, :daily_condition, :fun_condition, :content)
  end
end
