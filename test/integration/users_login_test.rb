require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with valid email/invalid password" do
    get login_path #visit the login path
    assert_template 'sessions/new' #verify the new sessions form renders properly
    post login_path, params: { session: { email: @user.email, password: "invalid" } } # Invalid password
    assert_not is_logged_in? # Assert not to log in
    assert_template 'sessions/new' #verify the sessions form gets re-rendered and a flash message appears
    assert_not flash.empty? #verify the flash message does not disappear and remains
    get root_path #visit another page
    assert flash.empty? #verify the flash disappears
  end

  test "login with valid information followed by logout" do
    get login_path # GET request
    post login_path, params: { session: { email: @user.email, password: 'password' } } # POST request
    assert is_logged_in? # Assert if logged in correctly
    assert_redirected_to @user # Assert if this is correctly redirected to @user
    follow_redirect! # Follow a single redirecting response
    assert_template 'users/show' # Assert if the show template is correctly chosen 
    assert_select "a[href=?]", login_path, count: 0 # Assert the existence of login_path (count: 0)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  
end
