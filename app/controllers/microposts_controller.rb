class MicropostsController < ApplicationController

  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  # POST /microposts
  def create
    @micropost = current_user.microposts.build(micropost_params)
    # ActiveStorage追加によりimageメソッドが追加される　imageを添付する　strong parameterにもimageを追加
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      # 
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  # DELETE /micropost/:id   micropostに入っているidを削除する
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user # micropostに入っているidを取得
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
    
end
