class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  layout "after_login"
end