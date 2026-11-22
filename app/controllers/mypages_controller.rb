class MypagesController < AuthenticatedController
  before_action :set_posts
  def show
  end

  private
  
  def set_posts
    # ログインユーザーの投稿をまとめて取得する
    @posts = current_user.posts.includes(:user, :group).order(created_at: :desc)
  end
end
