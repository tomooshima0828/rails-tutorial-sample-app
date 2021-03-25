class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  def logged_in_user
    unless logged_in? # ログインしていない場合(current_userが存在しない場合)に以下を行う
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
  
end
