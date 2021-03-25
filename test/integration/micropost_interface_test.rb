require 'test_helper'

class MicropostInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    # div id = "error_explanation" エラーメッセージ部分の表示
    assert_select 'div#error_explanation'
    # ページネーションのリンクが正しく機能するかどうか
    assert_select 'a[href=?]', '/?page=2'
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end

    assert_redirected_to root_url
    # 指定されたリダイレクト先に移動
    follow_redirect!
    # Returns the body of the HTTP response sent by the controller
    assert_match content, response.body
    # <a>タグにdeleteがあるかどうか
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  
end
