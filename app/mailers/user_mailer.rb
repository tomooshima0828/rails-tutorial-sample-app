class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, # メールの送付先
         subject: "Account activation" # subjectは固定
    # => return: mail object (text/html)
  end

  # @user.send_password_reset_email
  # UserMailer.account_activation(self).deliver_now /// self == @user
  # @userがmailオブジェクトに入る
  def password_reset(user)
    @user = user
    mail to: user.email,
         subject: "Password reset"
  end
end
