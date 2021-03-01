class UsersController < ApplicationController
  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end
  
  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users (+ params)
  def create
    @user = User.new(user_params)
      if @user.save
        flash[:success] = "Welcome to the sample app!"
        # flash.each do |message_type => [:success], message => "Welcome to the sample app!"|
        redirect_to @user
      else
        render 'new'
      end

  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
