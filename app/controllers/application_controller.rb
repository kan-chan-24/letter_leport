class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Deviseコントローラーを起動した時だけconfigure_permitted_parametersを読み込む
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # 新規登録（:sign_up）のときに、name も受け取ってOKとDeviseに伝える
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # 新規登録が成功すると作用する
  # ログイン・新規登録後の移動先を決める
  def after_sign_in_path_for(resource)
    # トークンを取り出す（同時にセッションから消える）
    token = session.delete(:invite_token)
    group = Group.find_by(invite_token: token) if token

    # 招待経由でなければ個人ページへ
    return mypage_path if group.nil?

    # 招待経由の場合に限り下記の処理が行われる
    member = group.add_member(resource)
    flash[:notice] = "#{group.name}に参加しました" if member.previously_new_record?

    group_path(group)
  end
end
