class StaticPagesController < ApplicationController
  before_action :redirect_if_signed_in, only: :top

  def top
  end

  private

  # ログイン時にトップへアクセスすると個人ページへ戻される
  def redirect_if_signed_in
    # redirect_to mypage_path if user_signed_in?
  end
end
