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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
  
  # 新規登録が成功するとそのままログイン状態にする
  def after_sign_in_path_for(resource)
    mypage_path
  end
end
