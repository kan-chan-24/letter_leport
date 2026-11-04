class InvitationsController < ApplicationController
  def show
    # 招待トークンで該当するグループを検索
    @group = Group.find_by(invite_token: params[:token])
    # トークンが見つからない（無効）の場合、見当たらない用のトークン無効ページを表示
    return render :invalid, status: :not_found if @group.nil?

    # ここから下は、グループが見つかったときだけ実行される
    @members = @group.users
    session[:invite_token] = params[:token] unless user_signed_in?
  end
end
