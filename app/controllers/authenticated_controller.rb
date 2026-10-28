class AuthenticatedController < ApplicationController
  # ログイン後の親クラス、ログイン後のレイアウトファイルの読み込みとログイン真偽チェック
  before_action :authenticate_user!
  layout "after_login"
end
