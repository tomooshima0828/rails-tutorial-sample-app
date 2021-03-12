class SessionsController < ApplicationController
  def new
  end
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      flash[:success] = "Successfully logged in!!!"
      log_in(user)
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash.now[:danger] = "Invalid login information/Login failed"
      render 'new'
    end
    
  end
  def destroy
    log_out if logged_in?
    flash[:success] = "Successfully logged out!!!"
    redirect_to root_url
  end
end
