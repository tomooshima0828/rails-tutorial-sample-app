require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path # GET password_resets#new
    assert_template 'password_resets/new' # Correctly rendering the template "Forgot password"

    # HTMLタグ'input[name=?]'が存在する / ?には第2引数'password_reset[email]'が入る
    # scope: :password_reset => params[:password_reset] to password_resets#create
    # ERB: f.email_field :email, class: 'form-control'
    # HTML: <input class="form-control" type="email" name="password_reset[email]" id="password_reset_email">
    assert_select 'input[name=?]', 'password_reset[email]' 

    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # メールアドレスが有効
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # パスワード再設定フォームのテスト
    # setup @user = users(:michael) @user attr:reset_tokenを取得できる
    user = assigns(:user)
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # toggle: ActiveRecord::Persistence#toggle / booleanなカラム名を渡すと、反転 trueならばfalse falseならばtrue
    # userの以下のキー（:activated）の値をtoggle!メソッドで反転（無効なユーザーに） true => false
    user.toggle!(:activated) # ユーザーが無効なユーザーになる
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url

    user.toggle!(:activated) # ユーザーが有効に戻る

    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'

    # <input type="hidden" name="_method" value="patch">
    # <input type="hidden" name="authenticity_token" value="m6NnEXNgImMjArMuLLMl0qfIE0V1NjbkSgTAi8HZyEcMxoFMN4iGQGzv66Jl55FbxlaUchPhzX59UsnzOPNjqg==">
    # <input type="hidden" name="email" id="email" value="admin@example.com">
    assert_select "input[name=email][type=hidden][value=?]", user.email
    
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'

    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }

    assert_select 'div#error_explanation'

    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
                            
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end  
end
