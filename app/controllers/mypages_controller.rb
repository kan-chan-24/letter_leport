class MypagesController < ApplicationController
  before_action :authenticate_user!
  layout "after_login"

  def show
  end
end
