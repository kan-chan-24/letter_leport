class ReactionsController < AuthenticatedController
  before_action :set_group
  before_action :set_post

  def create
    current_user.reactions.create(post: @post, stamp: params[:stamp])
    render_reactions
  end

  def destroy
    current_user.reactions.find_by(id: params[:id], post: @post)&.destroy
    render_reactions
  end

  private

  def set_group
    # PostsControllerと同じ。メンバーでないグループは見つからない＝👍できない
    @group = current_user.groups.find_by(id: params[:group_id])
    redirect_to mypage_path, alert: "このグループにはアクセスできません" unless @group
  end

  def set_post
    # 「このグループの投稿」の中から探す（他グループの投稿IDを指定されても見つからない）
    @post = @group.posts.find(params[:post_id])
  end

  def render_reactions
    # TL画面と同じ形のデータを、この投稿1件分だけ用意する
    reaction_counts = @post.reactions.group(:post_id, :stamp).count
    my_reactions = current_user.reactions.where(post: @post).index_by { |r| [ r.post_id, r.stamp ] }

    render turbo_stream: turbo_stream.replace(
      helpers.dom_id(@post, :reactions),
      partial: "reactions/reactions",
      locals: { group: @group, post: @post, reaction_counts: reaction_counts, my_reactions: my_reactions }
    )
  end
end
