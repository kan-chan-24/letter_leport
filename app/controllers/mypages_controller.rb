class MypagesController < AuthenticatedController
  before_action :set_posts
  def show
  end

  private
  
  def set_posts
    # ログインユーザーの投稿をまとめて取得する
    @posts = current_user.posts.includes(:user).order(created_at: :desc)
    p @posts.to_a
  end
end
